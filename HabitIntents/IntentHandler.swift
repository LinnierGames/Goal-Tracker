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
    case is INFeelingSleepyIntent:
      return INFeelingSleepyIntentHandler()
    default:
      return self
    }
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

    let newItem = Sleep(context: viewContext)
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
