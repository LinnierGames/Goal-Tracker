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
      TabView {
        DataCollectorScreen()
          .tabItem {
              Label("Data", systemImage: "antenna.radiowaves.left.and.right")
          }
        ReportsScreen()
          .tabItem {
              Label("Reports", systemImage: "newspaper")
          }
      }
      .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}
