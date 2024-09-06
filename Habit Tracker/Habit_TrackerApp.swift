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

  @State private var exitAppUponBackgrounding: Task<Void, Never>?

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
        GoalDashboardsScreen()
          .tabItem {
            Label("Goals", systemImage: "star.fill")
          }
      }
      .onReceive(
        NotificationCenter.default.publisher(
        for: UIApplication.didEnterBackgroundNotification)
      ) { _ in
          exitAppUponBackgrounding = Task {
            try? await Task.sleep(for: .seconds(10), tolerance: .seconds(5))
            guard !Task.isCancelled else { return }
//            exit(0)
          }
      }
      .onReceive(
        NotificationCenter.default.publisher(
        for: UIApplication.willEnterForegroundNotification)
      ) { _ in
          exitAppUponBackgrounding?.cancel()
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
