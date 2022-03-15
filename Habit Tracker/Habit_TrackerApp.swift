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
