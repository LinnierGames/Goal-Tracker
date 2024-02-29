//
//  Tracker_TrackerApp.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 3/11/22.
//

import SwiftUI

// TODO: try Conversational Intents for "Mark eating "cearal" for "breakfast"

@main
struct Tracker_TrackerApp: App {
  let persistenceController = PersistenceController.shared

  @ObservedObject var syncManager =
    ExternalSyncManager()
      .attach(source: HealthKitSync())
      .sync()

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
        TrackersScreen()
          .tabItem {
            Label("Trackers", systemImage: "text.book.closed")
          }
        GoalsScreen()
          .tabItem {
            Label("Goals", systemImage: "star.fill")
          }
      }
      .environment(\.managedObjectContext, persistenceController.container.viewContext)
      .environmentObject(syncManager)
    }
  }
}

struct Scratchpad_Previews: PreviewProvider {
  static var previews: some View {
    Menu {
      Button(
        action: {
        },
        title: "Count",
        systemImage: "chart.bar.fill"
      )

      Button(
        action: {
        },
        title: "Frequency",
        systemImage: "chart.xyaxis.line"
      )
    } label: {
      Text("Create New Chart")
        .font(.caption)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.15))
        .cornerRadius(8)
      //          Button {
      //          } label: {
      //          }
      //          .buttonStyle(.bordered)
    }
  }
}
