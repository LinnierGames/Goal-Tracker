//
//  INLogTrackerIntentHandler.swift
//  HabitIntents
//
//  Created by Erick Sanchez on 2/1/23.
//

import CoreData
import Intents

class INLogTrackerIntentHandler: NSObject, INLogTrackerIntentHandling {
  private let viewContext = PersistenceController.shared.container.viewContext

  // MARK: - Tracker

  func provideTrackerOptionsCollection(
    for intent: INLogTrackerIntent, searchTerm: String?
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

  func resolveTracker(for intent: INLogTrackerIntent) async -> INTrackerResolutionResult {
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

  // MARK: - Handle

  func handle(intent: INLogTrackerIntent) async -> INLogTrackerIntentResponse {
    guard let tracker = intent.tracker else {
      return INLogTrackerIntentResponse(code: .failure, userActivity: nil)
    }

    if let fieldValues = intent.values {
      createLog(for: tracker, fieldValues: fieldValues)
    } else {
      createLog(for: tracker, fieldValues: [])
    }

    return INLogTrackerIntentResponse(code: .success, userActivity: nil)
  }

  private func createLog(for inTracker: INTracker, fieldValues inFieldValues: [INTrackerLogValue]) {
    let tracker = inTracker.tracker(in: viewContext)

    let newLog = TrackerLog(context: viewContext)
    newLog.timestamp = Date()

    for inFieldValue in inFieldValues {
      guard inFieldValue.field?.tracker?.identifier == inTracker.identifier else { continue }

      let newLogValue = TrackerLogValue(context: viewContext)
      newLogValue.log = newLog
      newLogValue.field = inFieldValue.field!.field(in: viewContext)
      newLogValue.setValue(intentValue: inFieldValue, context: viewContext)
      newLog.addToValues(newLogValue)
    }

    tracker.addToLogs(newLog)

    try! viewContext.save()

    // FIXME: notify the main app of new updates to the database
    // https://www.avanderlee.com/swift/core-data-app-extension-data-sharing/#using-darwin-notifications-for-communication-between-extensions-and-your-main-app
  }
}
