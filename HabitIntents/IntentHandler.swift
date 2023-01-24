//
//  IntentHandler.swift
//  HabitIntents
//
//  Created by Erick Sanchez on 3/11/22.
//

import Intents

class IntentHandler: INExtension {

  override func handler(for intent: INIntent) -> Any {
    // This is the default implementation.  If you want different objects to handle different intents,
    // you can override this and return the handler you want for that particular intent.
    switch intent {
    case is INLogTrackerIntent:
      return INLogTrackerIntentHandler()
    case is INFeelingSleepyIntent:
      return INFeelingSleepyIntentHandler()
    case is INShowerTimestampIntent:
      return INShowerTimestampIntentHandler()
    default:
      return self
    }
  }

}

class INLogTrackerIntentHandler: NSObject, INLogTrackerIntentHandling {

  private let viewContext = PersistenceController.shared.container.viewContext

  func provideTrackerOptionsCollection(for intent: INLogTrackerIntent, searchTerm: String?) async throws -> INObjectCollection<INTracker> {
    let allTrackers = Habit.fetchRequest()
    allTrackers.sortDescriptors = [NSSortDescriptor(keyPath: \Habit.title, ascending: true)]
    let coreDataTrackers = try! viewContext.fetch(allTrackers)
    let trackers = coreDataTrackers.map { tracker in
      INTracker(
        identifier: tracker.objectID.uriRepresentation().absoluteString,
        display: tracker.title!
      )
    }

    return INObjectCollection(items: trackers)
  }

  func resolveTracker(for intent: INLogTrackerIntent) async -> INTrackerResolutionResult {
    if let tracker = intent.tracker {
      return .success(with: tracker)
    } else {
      let allTrackers = Habit.fetchRequest()
      allTrackers.sortDescriptors = [NSSortDescriptor(keyPath: \Habit.title, ascending: true)]
      let coreDataTrackers = try! viewContext.fetch(allTrackers)
      let trackers = coreDataTrackers.map { tracker in
        INTracker(
          identifier: tracker.objectID.uriRepresentation().absoluteString,
          display: tracker.title!
        )
      }

      return .disambiguation(with: trackers)
    }
  }

  func handle(intent: INLogTrackerIntent) async -> INLogTrackerIntentResponse {
    guard let tracker = intent.tracker else {
      return INLogTrackerIntentResponse(code: .failure, userActivity: nil)
    }

    createLog(for: tracker)

    return INLogTrackerIntentResponse(code: .success, userActivity: nil)
  }

  private func createLog(for inTracker: INTracker) {
    let trackerURLString = inTracker.identifier!
    let trackerURL = URL(string: trackerURLString)!

    let managedObjectID =
      viewContext.persistentStoreCoordinator!.managedObjectID(forURIRepresentation: trackerURL)!
    let tracker = viewContext.object(with: managedObjectID) as! Habit

    let newEntry = HabitEntry(context: viewContext)
    newEntry.timestamp = Date()
    tracker.addToEntries(newEntry)

    try! viewContext.save()

    // FIXME: notify the main app of new updates to the database
  }
}

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
