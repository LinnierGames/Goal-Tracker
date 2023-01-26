//
//  Tracker_TrackerApp.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 3/11/22.
//

import SwiftUI

@main
struct Tracker_TrackerApp: App {
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
