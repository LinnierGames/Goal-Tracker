//
//  INTrackerLogValueIntentHandler.swift
//  HabitIntents
//
//  Created by Erick Sanchez on 2/1/23.
//

import Intents

class INTrackerLogValueIntentHandler: NSObject, INTrackerLogValueIntentHandling {
  private let viewContext = PersistenceController.shared.container.viewContext

  // MARK: - Tracker

  func provideTrackerOptionsCollection(
    for intent: INTrackerLogValueIntent, searchTerm: String?
  ) async throws -> INObjectCollection<INTracker> {
    let allTrackers = Tracker.fetchRequest()
    if let searchTerm {
      allTrackers.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchTerm)
    }
    allTrackers.sortDescriptors = [NSSortDescriptor(keyPath: \Tracker.title, ascending: true)]
    let coreDataTrackers = try! viewContext.fetch(allTrackers)
    let trackers = coreDataTrackers.map { tracker in
      INTracker(
        identifier: tracker.encodeIntentIdentifier(),
        display: tracker.title!
      )
    }

    return INObjectCollection(items: trackers)
  }

  func resolveTracker(for intent: INTrackerLogValueIntent) async -> INTrackerResolutionResult {
    if let tracker = intent.tracker {
      return .success(with: tracker)
    } else {
      let allTrackers = Tracker.fetchRequest()
      allTrackers.sortDescriptors = [NSSortDescriptor(keyPath: \Tracker.title, ascending: true)]
      let coreDataTrackers = try! viewContext.fetch(allTrackers)
      let trackers = coreDataTrackers.map { tracker in
        INTracker(
          identifier: tracker.encodeIntentIdentifier(),
          display: tracker.title!
        )
      }

      return .disambiguation(with: trackers)
    }
  }

  // MARK: - Field

  func provideFieldOptionsCollection(for intent: INTrackerLogValueIntent, searchTerm: String?) async throws -> INObjectCollection<INTrackerLogField> {
    guard let tracker = intent.tracker else {
      return INObjectCollection(items: [])
    }

    let fieldsForTracker = TrackerLogField.fetchRequest()
    fieldsForTracker.predicate = NSPredicate(format: "tracker = %@", tracker.tracker(in: viewContext))
    fieldsForTracker.sortDescriptors = [NSSortDescriptor(keyPath: \Tracker.title, ascending: true)]
    let coreDataFields = try! viewContext.fetch(fieldsForTracker)
    let fields = coreDataFields.map { field in
      let field = INTrackerLogField(
        identifier: field.encodeIntentIdentifier(),
        display: field.title!
      )
      field.tracker = tracker

      return field
    }

    return INObjectCollection(items: fields)
  }

  // MARK: - Values

  func resolveStringValue(for intent: INTrackerLogValueIntent) async -> INTrackerLogValueStringValueResolutionResult {
    if let stringValue = intent.stringValue {
      guard let intentField = intent.field else {
        fatalError("should not set this field without setting the parent param; field")
      }

      let field = intentField.field(in: viewContext)

      guard field.type == .string else {
        return .unsupported(forReason: .wrongFieldType)
      }

      return .success(with: stringValue)
    } else {
      return .success(with: "")
    }
  }

  func resolveIntegerValue(for intent: INTrackerLogValueIntent) async -> INTrackerLogValueIntegerValueResolutionResult {
    if let nsNumber = intent.integerValue {
      guard let intentField = intent.field else {
        fatalError("should not set this field without setting the parent param; field")
      }

      let field = intentField.field(in: viewContext)

      guard field.type == .integer else {
        return .unsupported(forReason: .wrongFieldType)
      }

      return .success(with: nsNumber.intValue)
    } else {
      return .success(with: 0)
    }
  }

  func resolveDoubleValue(for intent: INTrackerLogValueIntent) async -> INTrackerLogValueDoubleValueResolutionResult {
    if let nsNumber = intent.doubleValue {
      guard let intentField = intent.field else {
        fatalError("should not set this field without setting the parent param; field")
      }

      let field = intentField.field(in: viewContext)

      guard field.type == .double else {
        return .unsupported(forReason: .wrongFieldType)
      }

      return .success(with: nsNumber.doubleValue)
    } else {
      return .success(with: 0)
    }
  }

  func resolveBoolValue(for intent: INTrackerLogValueIntent) async -> INTrackerLogValueBoolValueResolutionResult {
    if let nsNumber = intent.boolValue {
      guard let intentField = intent.field else {
        fatalError("should not set this field without setting the parent param; field")
      }

      let field = intentField.field(in: viewContext)

      guard field.type == .boolean else {
        return .unsupported(forReason: .wrongFieldType)
      }

      return .success(with: nsNumber.boolValue)
    } else {
      return .success(with: false)
    }
  }

  // MARK: - Handle

  func handle(intent: INTrackerLogValueIntent) async -> INTrackerLogValueIntentResponse {
    guard let field = intent.field else {
      return INTrackerLogValueIntentResponse(code: .failure, userActivity: nil)
    }

    let result = INTrackerLogValueIntentResponse(code: .success, userActivity: nil)
    let logValue = INTrackerLogValue(identifier: nil, display: "Field")
    logValue.field = field
    switch field.field(in: viewContext).type {
    case .string:
      logValue.stringValue = intent.stringValue
    case .integer:
      logValue.integerValue = intent.integerValue
    case .double:
      logValue.doubleValue = intent.doubleValue
    case .boolean:
      logValue.boolValue = intent.boolValue
    }
    result.value = logValue

    return result
  }
}
