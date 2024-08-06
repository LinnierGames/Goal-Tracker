//
//  TrackerLog.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 2/20/23.
//

import CoreData
import SwiftUI

enum TrackerLogCompletion: Int16, Identifiable {
  case complete = 0, missed, skip

  var id: Self { self }

  var systemName: String {
    switch self {
    case .complete: "checkmark"
    case .missed: "xmark"
    case .skip: "chevron.forward.2"
    }
  }

  func color(isTrackerBad: Bool) -> Color {
    switch self {
    case .complete: isTrackerBad ? .red : .green
    case .missed: isTrackerBad ? .green : .red
    case .skip: .gray
    }
  }
}

struct TrackerLogCompletionView: View {
  @Binding var completion: TrackerLogCompletion
  let isTrackerBad: Bool

  init(_ completion: Binding<TrackerLogCompletion>, isTrackerBad: Bool) {
    self._completion = completion
    self.isTrackerBad = isTrackerBad
  }

  var body: some View {
    HStack(spacing: 0) {
      ForEach([.complete, .missed, .skip]) { (option: TrackerLogCompletion) in
        Button {
          withAnimation {
            completion = option
          }
        } label: {
          if option == completion {
            Image(systemName: option.systemName)
              .foregroundStyle(.white)
              .padding()
              .background(option.color(isTrackerBad: isTrackerBad))
          } else {
            Image(systemName: option.systemName)
              .foregroundStyle(.white)
              .padding()
          }
        }
        .buttonStyle(.borderless)
      }
    }
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}

extension TrackerLog {
  var completion: TrackerLogCompletion {
    get { TrackerLogCompletion(rawValue: completionRawValue) ?? .complete }
    set { completionRawValue = newValue.rawValue }
  }

  var completionColor: Color {
    if let tracker {
      switch completion {
      case .complete: tracker.isBadTracker ? .red : .green
      case .missed: tracker.isBadTracker ? .green : .red
      case .skip: .gray
      }
    } else {
      switch completion {
      case .complete: .green
      case .missed: .red
      case .skip: .gray
      }
    }
  }

  var completionLabel: some View {
    Image(systemName: completion.systemName)
  }
  
  /// `true` if the log is the tracker's expected completion
  var isTrackerCompletion: Bool {
    if completion == .skip {
      false
    } else if let tracker {
      if
        tracker.isBadTracker && completion == .missed
          || !tracker.isBadTracker && completion == .complete
      {
        true
      } else {
        false
      }
    } else {
      false
    }
  }

  var allValues: [TrackerLogValue] {
    values?.allManagedObjects() ?? []
  }
  
  /// Formatted string
  @objc var timestampFormat: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, d 'at' HH:mm"
    return formatter.string(from: timestamp!)
  }

  @objc var timestampWeek: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM yyyy, 'week' F"
    return formatter.string(from: timestamp!)
  }

  static func copy(_ log: TrackerLog, in context: NSManagedObjectContext) -> TrackerLog {
    let copy = TrackerLog(context: context)
    copy.timestamp = log.timestamp
    copy.endDate = log.endDate
    copy.completionRawValue = log.completionRawValue
    copy.notes = log.notes
    copy.externalDataSourceID = log.externalDataSourceID

    copy.tracker = log.tracker

    for value in log.allValues {
      let copyValue = TrackerLogValue.copy(value, in: context)
      copy.addToValues(copyValue)
    }

    return copy
  }
}

enum TrackerLogFieldType: Int16, CaseIterable, Identifiable {
  var id: Int16 { rawValue }

  case string, integer, boolean, double

  var description: String {
    switch self {
    case .string:
      return "String"
    case .integer:
      return "Integer"
    case .boolean:
      return "True/False"
    case .double:
      return "Decimal"
    }
  }
}

extension TrackerLogField {
  var type: TrackerLogFieldType {
    get {
      TrackerLogFieldType(rawValue: typeRawValue)!
    }
    set {
      typeRawValue = newValue.rawValue
    }
  }

  func encodeIntentIdentifier() -> String {
    "\(objectID.uriRepresentation().absoluteString) \(type.description)"
  }

  static func decodeIntentIdentifier(
    _ identifer: String,
    coordinator: NSPersistentStoreCoordinator
  ) -> (objectID: NSManagedObjectID, fieldType: TrackerLogFieldType)? {
    let components = identifer.split(separator: " ")
    guard components.count == 2, let objectURL = URL(string: String(components[0])) else {
      assertionFailure("Decoding failed")
      return nil
    }

    guard let managedObjectID = coordinator.managedObjectID(forURIRepresentation: objectURL) else {
      assertionFailure("Decoding failed: invalid managed object ID")
      return nil
    }

    let fieldType: TrackerLogFieldType
    switch components[1] {
    case TrackerLogFieldType.string.description:
      fieldType = .string
    case TrackerLogFieldType.integer.description:
      fieldType = .integer
    case TrackerLogFieldType.double.description:
      fieldType = .double
    case TrackerLogFieldType.boolean.description:
      fieldType = .boolean
    default:
      assertionFailure("Decoding failed: invalid field type")
      return nil
    }

    return (managedObjectID, fieldType)
  }
}

extension TrackerLogValue {
  var string: String {
    switch field!.type {
    case .string:
      return stringValue ?? ""
    case .integer:
      return String(integerValue)
    case .double:
      return String(doubleValue)
    case .boolean:
      return boolValue ? "True" : "False"
    }
  }

  static func copy(_ value: TrackerLogValue, in context: NSManagedObjectContext) -> TrackerLogValue {
    let copy = TrackerLogValue(context: context)
    copy.boolValue = value.boolValue
    copy.doubleValue = value.doubleValue
    copy.integerValue = value.integerValue
    copy.stringValue = value.stringValue

    copy.field = value.field
    copy.log = value.log

    return copy
  }
}

extension Array<TrackerLogValue> {
  func filter(
    fieldTitle: String,
    predicate: KeyPath<TrackerLogValue, Bool>
  ) -> [TrackerLogValue] {
    filter { $0.field?.title == fieldTitle }
      .filter { $0[keyPath: predicate] }
  }
  func filter(
    fieldTitle: String,
    predicate: (TrackerLogValue) -> Bool = { _ in true }
  ) -> [TrackerLogValue] {
    filter { $0.field?.title == fieldTitle }
      .filter(predicate)
  }

  func contains(
    fieldTitle: String,
    predicate: (TrackerLogValue) -> Bool = { _ in true }
  ) -> Bool {
    filter { $0.field?.title == fieldTitle }
      .contains(where: predicate)
  }
  func contains(
    fieldTitle: String,
    predicate: KeyPath<TrackerLogValue, Bool>
  ) -> Bool {
    filter { $0.field?.title == fieldTitle }
      .contains { $0[keyPath: predicate] }
  }

  func first(
    fieldTitle: String,
    predicate: KeyPath<TrackerLogValue, Bool>
  ) -> TrackerLogValue? {
    guard
      let valueByField = first(where: { $0.field?.title == fieldTitle })
    else {
      return nil
    }

    return if valueByField[keyPath: predicate] {
      valueByField
    } else {
      nil
    }
  }
  func first(
    fieldTitle: String,
    predicate: (TrackerLogValue) -> Bool = { _ in true }
  ) -> TrackerLogValue? {
    guard
      let valueByField = first(where: { $0.field?.title == fieldTitle })
    else {
      return nil
    }

    return if predicate(valueByField) {
      valueByField
    } else {
      nil
    }
  }
}

//Tracker
//+ fields
//++ title
//++ type
//++ logValues
//
//TrackerLog
//+ tracker
//+ fieldValues
//++ field
//++ intValue/stringValue/boolValue/floatValue
