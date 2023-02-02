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
    case is INTrackerLogValueIntent:
      return INTrackerLogValueIntentHandler()
    default:
      return self
    }
  }
}
