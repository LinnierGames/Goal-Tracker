//
//  GoalDashboardsScreen+Tracker.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 4/28/24.
//

import SwiftUI

/// Find the `Tracker` given the hardcoded tracker names
struct TrackersView<Label: View>: View {
  let trackerNames: [String]
  let content: ([Tracker]) -> Label

  @State private var missingTrackers: [String] = []
  @State private var trackers: [Tracker] = []
  @State private var detailTracker: Tracker?

  @Environment(\.managedObjectContext) var viewContext

  init(
    trackerNames t1: String,
    _ t2: String,
    @ViewBuilder
    label: @escaping (Tracker, Tracker) -> Label
  ) {
    trackerNames = [t1, t2]
    content = { trackers in
      label(trackers[0], trackers[1])
    }
  }

  init(
    trackerNames t1: String,
    _ t2: String,
    _ t3: String,
    @ViewBuilder
    label: @escaping (Tracker, Tracker, Tracker) -> Label
  ) {
    trackerNames = [t1, t2, t3]
    content = { trackers in
      label(trackers[0], trackers[1], trackers[2])
    }
  }

  init(
    trackerNames t1: String,
    _ t2: String,
    _ t3: String,
    _ t4: String,
    @ViewBuilder
    label: @escaping (Tracker, Tracker, Tracker, Tracker) -> Label
  ) {
    trackerNames = [t1, t2, t3, t4]
    content = { trackers in
      label(trackers[0], trackers[1], trackers[2], trackers[3])
    }
  }

  var body: some View {
    Group {
      if trackers.isEmpty {
        Text("Trackers not found: \(missingTrackers.joined(separator: ", "))")
      } else {
        content(trackers)
          .addLogContextMenu(viewContext: viewContext, trackers: trackers)
      }
    }.onAppear {
      do {
        var foundTrackers: [Tracker] = []
        for trackerName in trackerNames {
          let trackerByName = Tracker.fetchRequest()
          trackerByName.predicate = NSPredicate(format: "title == %@", trackerName)

          let result = try viewContext.fetch(trackerByName)

          if let tracker = result.first {
            foundTrackers.append(tracker)
          } else {
            missingTrackers.append(trackerName)
          }
        }

        guard foundTrackers.count == trackerNames.count else {
          return
        }

        trackers = foundTrackers
      } catch {
        trackers = []
        missingTrackers = []
        assertionFailure("Failed to fetch: \(error)")
      }
    }
  }
}

/// Find the `Tracker` given the hardcoded tracker name
struct TrackerView<Content: View>: View {
  let trackerName: String
  let content: (Tracker) -> Content
  @State private var tracker: Tracker?

  @Environment(\.managedObjectContext) var viewContext

  init(
    _ trackerName: String,
    @ViewBuilder content: @escaping (Tracker) -> Content
  ) {
    self.trackerName = trackerName
    self.content = content
  }

  var body: some View {
    Group {
      if let tracker {
        content(tracker)
          .addLogContextMenu(viewContext: viewContext, tracker: tracker)
      } else {
        Text("Tracker not found: \(trackerName)")
      }
    }.onAppear {
      do {
        let trackerByName = Tracker.fetchRequest()
        trackerByName.predicate = NSPredicate(format: "title == %@", trackerName)

        let result = try viewContext.fetch(trackerByName)

        if let tracker = result.first {
          self.tracker = tracker
        } else {
          self.tracker = nil
        }
      } catch {
        self.tracker = nil
      }
    }
  }
}
