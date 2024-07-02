//
//  Tracker.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/17/23.
//

import CoreData
import SwiftUI

extension Tracker {

  @ViewBuilder
  var completionLabel: some View {
    if isBadTracker {
      Image(systemName: "xmark")
    } else {
      Image(systemName: "checkmark")
    }
  }

  var mostRecentLog: TrackerLog? {
    allLogs
      .sorted { $0.timestamp! > $1.timestamp! }
      .first
  }

  var allLogs: [TrackerLog] {
    logs?.allManagedObjects() ?? []
  }

  var allTags: [TrackerTag] {
    tags?.allManagedObjects() ?? []
  }

  var allFields: [TrackerLogField] {
    fields?.allManagedObjects() ?? []
  }

  func encodeIntentIdentifier() -> String {
    "\(objectID.uriRepresentation().absoluteString) \(allFields.isEmpty ? "HAS_NO_FIELDS" : "HAS_FIELDS")"
  }

  static func decodeIntentIdentifier(
    _ identifer: String,
    coordinator: NSPersistentStoreCoordinator
  ) -> (objectID: NSManagedObjectID, hasFields: Bool)? {
    let components = identifer.split(separator: " ")
    guard components.count == 2, let objectURL = URL(string: String(components[0])) else {
      assertionFailure("Decoding failed")
      return nil
    }

    guard let managedObjectID = coordinator.managedObjectID(forURIRepresentation: objectURL) else {
      assertionFailure("Decoding failed: invalid managed object ID")
      return nil
    }

    let hasFields: Bool
    switch components[1] {
    case "HAS_NO_FIELDS":
      hasFields = false
    case "HAS_FIELDS":
      hasFields = true
    default:
      assertionFailure("Decoding failed: invalid component")
      return nil
    }

    return (managedObjectID, hasFields)
  }
}

extension TrackerTag {
  var allTrackers: [Tracker] {
    trackers?.allManagedObjects() ?? []
  }

  func contains(_ tracker: Tracker) -> Bool {
    allTrackers.contains(tracker)
  }
}
