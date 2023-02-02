//
//  Common.swift
//  HabitIntents
//
//  Created by Erick Sanchez on 2/1/23.
//

import Foundation
import CoreData

extension TrackerLogValue {
  func setValue(intentValue: INTrackerLogValue, context: NSManagedObjectContext) {
    switch intentValue.field!.field(in: context).type {
    case .string:
      stringValue = intentValue.stringValue
    case .integer:
      integerValue = intentValue.integerValue.map { $0.int64Value } ?? 0
    case .double:
      doubleValue = intentValue.doubleValue.map { $0.doubleValue } ?? 0
    case .boolean:
      boolValue = intentValue.boolValue.map { $0.boolValue } ?? false
    }
  }
}

extension INTracker {
  func tracker(in context: NSManagedObjectContext) -> Tracker {
    let managedObjectID = Tracker.decodeIntentIdentifier(
      identifier!, coordinator: context.persistentStoreCoordinator!
    )!.objectID

    return context.object(with: managedObjectID) as! Tracker
  }
}

extension INTrackerLogField {
  func field(in context: NSManagedObjectContext) -> TrackerLogField {
    let managedObjectID = TrackerLogField.decodeIntentIdentifier(
      identifier!, coordinator: context.persistentStoreCoordinator!
    )!.objectID

    return context.object(with: managedObjectID) as! TrackerLogField
  }
}
