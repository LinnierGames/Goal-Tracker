//
//  Habit_TrackerApp.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 3/11/22.
//

import SwiftUI

@main
struct Habit_TrackerApp: App {
  let persistenceController = PersistenceController.shared

  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}

import Intents

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

    INPreferences.requestSiriAuthorization { status in
      switch status {
      case .notDetermined, .restricted, .denied:
        print("no siri")
      case .authorized:
        print("yes siri")
      }
    }

    //  let sleepy = INFeelingSleepyIntent()
    //  sleepy.suggestedInvocationPhrase = "Mark feeling tired"
    //  sleepy.activity = "Use iPhone"
    //
    //  let interaction = INInteraction(intent: sleepy, response: nil)
    //  interaction.donate { error in
    //    if let error = error {
    //      print("failed to donate: \(error.localizedDescription)")
    //    } else {
    //      print("donated!")
    //    }
    //  }

    return true
  }
}
