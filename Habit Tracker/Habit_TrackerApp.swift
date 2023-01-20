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
        TodayScreen()
          .tabItem {
            Label("Today", systemImage: "calendar")
          }
        ImportDataScreen()
          .tabItem {
            Label("Import", systemImage: "square.and.arrow.down")
          }
        HabitsScreen()
          .tabItem {
            Label("Habits", systemImage: "text.book.closed")
          }
        GoalsScreen()
          .tabItem {
            Label("Goals", systemImage: "star.fill")
          }
      }
      .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}

struct OldApp: View {
  let persistenceController: PersistenceController

  var body: some View {
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

struct Scratchpad_Previews: PreviewProvider {
  static var previews: some View {
    Button("New Chart") {}
//      .tint(.red)
//      .controlSize(.small) // .large, .medium or .small
//      .background(Color.blue)
  }
}
