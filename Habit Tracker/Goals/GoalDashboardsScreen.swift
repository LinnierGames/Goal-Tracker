//
//  GoalDashboardsScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 12/9/23.
//

import SwiftUI

struct GoalDashboardsScreen: View {
  @Environment(\.dismiss) var dismiss
  @Environment(\.managedObjectContext) var viewContext

  var body: some View {
    NavigationView {
//      ScrollView {
//        LazyVStack {
//          sleepSection
//        }
//      }
      Form {
        sleepSection
      }
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Done", action: dismiss.callAsFunction)
        }
      }
      .navigationTitle("Dashboards")
      .navigationBarTitleDisplayMode(.inline)
    }
//    .environment(date range)
  }

  private var sleepSection: some View {
    Section {
      TrackerView("Exercise", context: viewContext) { tracker in
        Text("Tracker found!")
//        DidCompleteChart(
//          tracker: tracker,
//          color: { log in
//            // log.timestamp isBetween 10pm and 11:30pm
//          }
//        )
      }
    } header: {
      Text("Sleep")
    }
  }
}

import CoreData

struct TrackerView<Content: View>: View {
  let trackerName: String
  let content: (Tracker) -> Content
  let tracker: Tracker?

  init(
    _ trackerName: String,
    context: NSManagedObjectContext,
    @ViewBuilder content: @escaping (Tracker) -> Content
  ) {
    self.trackerName = trackerName
    self.content = content

    do {
      let trackerByName = Tracker.fetchRequest()
      trackerByName.predicate = NSPredicate(format: "title == %@", trackerName)

      let result = try context.fetch(trackerByName)

      if let tracker = result.first {
        self.tracker = tracker
      } else {
        self.tracker = nil
      }
    } catch {
      self.tracker = nil
    }
  }

  var body: some View {
    if let tracker {
      content(tracker)
    } else {
      Text("Tracker not found: \(trackerName)")
    }
  }
}
