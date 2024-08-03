//
//  TrackerEntryDetailScreen.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/22/23.
//

import CoreData
import SwiftUI

struct TrackerLogDetailScreen: View {
  @ObservedObject var tracker: Tracker
  @ObservedObject var log: TrackerLog

  @State private var isKeyboardShowing = false

  @Environment(\.managedObjectContext)
  private var viewContext

  @Environment(\.dismiss)
  private var dismiss

  var body: some View {
    List {
      Section {
        HStack {
          Text("Did you complete this?")
          Spacer()
          TrackerLogCompletionView($log.completion, isTrackerBad: tracker.isBadTracker)
        }
      }
      Section {
        DatePicker(selection: $log.timestamp.mapOptional(defaultValue: Date())) {
          Label("Date", systemImage: "calendar")
        }

        if log.endDate != nil {
          DatePicker(selection: $log.endDate.mapOptional(defaultValue: Date())) {
            Label("End Date", systemImage: "calendar")
          }.swipeActions {
            Button(action: {
              log.endDate = nil
            }, title: "Remove", systemImage: "x.circle.fill")
          }
        } else {
          HStack {
            Label("End Date", systemImage: "calendar")
            Spacer()
            Button("Add End Date") {
              log.endDate = Date()
            }
          }
        }
      } footer: {
        if let endDate = log.endDate {
          let startDate = log.timestamp!
          if startDate > endDate {
            Text("Duration: \(endDate..<startDate, format: .timeDuration)")
          } else {
            Text("Duration: \(startDate..<endDate, format: .timeDuration)")
          }
        }
      }

      Section("Fields") {
        TrackerFieldValues(tracker: tracker, log: log)
      }
    }
    .listStyle(.grouped)
    .navigationTitle("Edit Entry")
//    .toolbar {
//      Button("Done") {
//        isKeyboardShowing = false
//      }
//      .isHidden(!isKeyboardShowing)
//    }

    .onChange(of: log.timestamp) {
      try! viewContext.save()
    }
    .onChange(of: log.endDate) {
      try! viewContext.save()
    }
    .onChange(of: log.completion) {
      try! viewContext.save()
    }
  }
}

private struct TrackerFieldValues: View {
  @ObservedObject var tracker: Tracker
  @ObservedObject var log: TrackerLog

  @FetchRequest
  private var fields: FetchedResults<TrackerLogField>

  @Environment(\.managedObjectContext)
  private var viewContext

  init(tracker: Tracker, log: TrackerLog) {
    self.tracker = tracker
    self.log = log
    self._fields = FetchRequest(
      sortDescriptors: [SortDescriptor(\TrackerLogField.title)],
      predicate: NSPredicate(format: "tracker = %@", tracker)
    )
  }

  var body: some View {
    if fields.isEmpty {
      HStack {
        Spacer()
        Text("No Custom Fields for this Tracker")
        Spacer()
      }
    } else {
      ForEach(fields) { field in
        FieldValue(log: log, field: field)
      }
    }
  }
}

private class FieldValueViewModel: ObservableObject {
  @ObservedObject var log: TrackerLog
  @ObservedObject var field: TrackerLogField

  private static let viewContext = PersistenceController.shared.container.viewContext

  enum Value {
    case string(String)
    case integer(Int)
    case boolean(Bool)
    case double(Double)

    var stringValue: String {
      switch self {
      case .string(let value):
        return value
      case .integer(let value):
        return String(value)
      case .double(let value):
        return String(value)
      case .boolean(let value):
        return value ? "True" : "False"
      }
    }

    var boolValue: Bool {
      switch self {
      case .string, .integer, .double:
        return false
      case .boolean(let value):
        return value
      }
    }
  }

  @Published var value: Value
  @Published var logValue: TrackerLogValue?

  init(log: TrackerLog, field: TrackerLogField) {
    self.log = log
    self.field = field

    let fetchValueForFieldInLog = TrackerLogValue.fetchRequest()
    fetchValueForFieldInLog.predicate =
      NSPredicate(format: "log = %@ AND field = %@", log, field)
    let results = try! Self.viewContext.fetch(fetchValueForFieldInLog)

    if results.count > 1 {
      fatalError("Should only have one values per field per log")
    } else if let value = results.first {
      switch (field.type, value.stringValue, value.integerValue, value.boolValue, value.doubleValue) {
      case (.string, let string?, _, _, _):
        self.value = .string(string)
        self.logValue = value
      case (.integer, _, let integer, _, _):
        self.value = .integer(Int(integer))
        self.logValue = value
      case (.boolean, _, _, let bool, _):
        self.value = .boolean(bool)
        self.logValue = value
      case (.double, _, _, _, let double):
        self.value = .double(double)
        self.logValue = value
      default:

        // Fallback to default
        switch field.type {
        case .string:
          self.value = .string("")
        case .integer:
          self.value = .integer(0)
        case .boolean:
          self.value = .boolean(false)
        case .double:
          self.value = .double(0)
        }

        self.logValue = nil
      }
    } else {

      // Fallback to default
      switch field.type {
      case .string:
        self.value = .string("")
      case .integer:
        self.value = .integer(0)
      case .boolean:
        self.value = .boolean(false)
      case .double:
        self.value = .double(0)
      }

      self.logValue = nil
    }
  }

  func set(stringValue: String) {
    updateValue { $0.stringValue = stringValue }
  }

  func set(integerValue: Int) {
    updateValue { $0.integerValue = Int64(integerValue) }
  }

  func set(doubleValue: Double) {
    updateValue { $0.doubleValue = doubleValue }
  }

  func set(boolValue: Bool) {
    updateValue { $0.boolValue = boolValue }
  }

  private func updateValue(modifer: (TrackerLogValue) -> Void) {
    if let logValue {
      modifer(logValue)
    } else {
      let newLogValue = TrackerLogValue(context: Self.viewContext)
      newLogValue.log = log
      newLogValue.field = field
      modifer(newLogValue)

      self.logValue = newLogValue
    }

    try! Self.viewContext.save()
  }
}

private struct FieldValue: View {
  @ObservedObject var log: TrackerLog
  @ObservedObject var field: TrackerLogField
  @StateObject private var viewModel: FieldValueViewModel

  init(log: TrackerLog, field: TrackerLogField) {
    self.log = log
    self.field = field
    self._viewModel = StateObject(
      wrappedValue: FieldValueViewModel(log: log, field: field)
    )
  }

  @State private var string = ""
  @State private var bool = false

  @FocusState private var isKeyboardShowing

  // FIXME: remove duplicate done buttons when there's multiple fields

  var body: some View {
    HStack {
      Text(field.title!)
      Spacer()
      switch viewModel.value {
      case .string:
        TextField(field.type.description, text: $string)
          .multilineTextAlignment(.trailing)
          .frame(width: 196)
          .onSubmit {
            viewModel.set(stringValue: string)
          }
          .focused($isKeyboardShowing)
          .toolbar {
            Button("Done") {
              isKeyboardShowing = false
              viewModel.set(stringValue: string)
            }
            .isHidden(!isKeyboardShowing)
          }
      case .integer:
        TextField(field.type.description, text: $string) // TODO: use value and format?
          .multilineTextAlignment(.trailing)
          .keyboardType(.numberPad)
          .frame(width: 196)
          .onSubmit {
            viewModel.set(integerValue: Int(string) ?? 0)
          }
          .focused($isKeyboardShowing)
          .toolbar {
            Button("Done") {
              isKeyboardShowing = false
              viewModel.set(integerValue: Int(string) ?? 0)
            }
            .isHidden(!isKeyboardShowing)
          }
      case .double:
        TextField(field.type.description, text: $string) // TODO: use a formater?
          .multilineTextAlignment(.trailing)
          .keyboardType(.decimalPad)
          .frame(width: 196)
          .onSubmit {
            viewModel.set(doubleValue: Double(string) ?? 0)
          }
          .focused($isKeyboardShowing)
          .toolbar {
            Button("Done") {
              isKeyboardShowing = false
              viewModel.set(doubleValue: Double(string) ?? 0)
            }
            .isHidden(!isKeyboardShowing)
          }
      case .boolean:
        Toggle(isOn: $bool) {
          EmptyView()
        }
        .onChange(of: bool) { newValue in
          viewModel.set(boolValue: newValue)
        }
      }
    }
    .onLoad {

      // Set up string or bool
      switch field.type {
      case .string, .integer, .double:
        self.string = self.viewModel.value.stringValue
      case .boolean:
        self.bool = self.viewModel.value.boolValue
      }
    }
  }
}
