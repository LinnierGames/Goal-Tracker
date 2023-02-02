//
//  IceBox.swift
//  HabitIntents
//
//  Created by Erick Sanchez on 2/1/23.
//

import Intents

class INFeelingSleepyIntentHandler: NSObject, INFeelingSleepyIntentHandling {
  func handle(intent: INFeelingSleepyIntent, completion: @escaping (INFeelingSleepyIntentResponse) -> Void) {
    guard let activity = intent.activity, activity.isEmpty == false else {
      return completion(INFeelingSleepyIntentResponse(code: .failure, userActivity: nil))
    }

    storeActivityIntoDB(activity: activity)
    completion(INFeelingSleepyIntentResponse(code: .success, userActivity: nil))
  }

  func resolveActivity(for intent: INFeelingSleepyIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
    guard let activity = intent.activity, activity.isEmpty == false else {
      return completion(.needsValue())
    }

    completion(.success(with: activity))
  }

  private func storeActivityIntoDB(activity: String) {
    let viewContext = PersistenceController.shared.container.viewContext

    let newItem = FeelingSleepy(context: viewContext)
    newItem.timestamp = Date()
    newItem.activity = activity

    do {
      try viewContext.save()
    } catch {
      // Replace this implementation with code to handle the error appropriately.
      // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      let nsError = error as NSError
      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
  }
}

class INShowerTimestampIntentHandler: NSObject, INShowerTimestampIntentHandling {
  func handle(intent: INShowerTimestampIntent, completion: @escaping (INShowerTimestampIntentResponse) -> Void) {

    // check when was the last time i used T-Gel.
    // if > 14 days ago, announce "time to use T-Gel"
    // else, continue

    // which things are you using: Green tea shampoo + conditioner, T-Gel + conditioner

    if let products = intent.products, !products.isEmpty {
      storeIntoDB(products: products)
    }

    completion(INShowerTimestampIntentResponse(code: .success, userActivity: nil))
  }

  func resolveProducts(for intent: INShowerTimestampIntent, with completion: @escaping ([INStringResolutionResult]) -> Void) {
    let products = intent.products ?? []
    completion(products.map { product in return .success(with: product) })
  }

  private func storeIntoDB(products: [String]) {
    let viewContext = PersistenceController.shared.container.viewContext

    let newItem = ShowerTimestamp(context: viewContext)
    newItem.timestamp = Date()
    newItem.products = products

    do {
      try viewContext.save()
    } catch {
      // Replace this implementation with code to handle the error appropriately.
      // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      let nsError = error as NSError
      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
  }
}


protocol TrackerIntent: INIntent {
  var tracker: INTracker? { get set }
}

extension INLogTrackerIntent: TrackerIntent {}

protocol INLogTrackerIntentHandlerBase: NSObject {
  associatedtype Intent: TrackerIntent

  func provideTrackerOptionsCollection(
    for intent: Intent, searchTerm: String?
  ) async throws -> INObjectCollection<INTracker>

  func resolveTracker(for intent: Intent) async -> INTrackerResolutionResult
}

extension INLogTrackerIntentHandlerBase {
  static var viewContext: NSManagedObjectContext {
    PersistenceController.shared.container.viewContext
  }

  func provideTrackerOptionsCollection(
    for intent: Intent, searchTerm: String?
  ) async throws -> INObjectCollection<INTracker> {
    let allTrackers = Tracker.fetchRequest()
    if let searchTerm {
      allTrackers.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchTerm)
    }
    allTrackers.sortDescriptors = [NSSortDescriptor(keyPath: \Tracker.title, ascending: true)]
    let coreDataTrackers = try! Self.viewContext.fetch(allTrackers)
    let trackers = coreDataTrackers.map { tracker in
      INTracker(
        identifier: tracker.encodeIntentIdentifier(),
        display: tracker.title!
      )
    }

    return INObjectCollection(items: trackers)
  }

  func resolveTracker(for intent: Intent) async -> INTrackerResolutionResult {
    if let tracker = intent.tracker {
      return .success(with: tracker)
    } else {
      let allTrackers = Tracker.fetchRequest()
      allTrackers.sortDescriptors = [NSSortDescriptor(keyPath: \Tracker.title, ascending: true)]
      let coreDataTrackers = try! Self.viewContext.fetch(allTrackers)
      let trackers = coreDataTrackers.map { tracker in
        INTracker(
          identifier: tracker.encodeIntentIdentifier(),
          display: tracker.title!
        )
      }

      return .disambiguation(with: trackers)
    }
  }
}
