//
//  TodayScreen.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/17/23.
//

import SwiftUI

struct TodayScreen: View {
  @Environment(\.managedObjectContext) private var viewContext

  @FetchRequest(
    sortDescriptors: [SortDescriptor(\Tracker.title!)],
    predicate: NSPredicate(format: "showInTodayView == YES")
  )
  private var trackers: FetchedResults<Tracker>

  @FetchRequest(
    sortDescriptors: [SortDescriptor(\TrackerLog.timestamp, order: .reverse)],
    predicate: NSPredicate(
      format: "timestamp >= %@ AND timestamp < %@ AND tracker.showInTodayView == NO",
      Date().midnight as NSDate,
      Date().addingTimeInterval(.init(days: 1)).midnight as NSDate
    )
  )
  private var logsForToday: FetchedResults<TrackerLog>

  var body: some View {
    NavigationView {
      List {
        ForEach(trackers) { tracker in
          TodayTrackerCell(tracker)
        }

        if !logsForToday.isEmpty {
          Section("Other Trackers") {
            ForEach(logsForToday) { log in
              TodayTrackerCell(log.tracker!, entryOverride: log)
            }
          }
        }
      }
      .navigationTitle("Today")
    }
  }
}

struct TodayTrackerCell: View {
  let entryOverride: TrackerLog?
  @ObservedObject var tracker: Tracker

  @Environment(\.managedObjectContext)
  private var viewContext

  init(_ tracker: Tracker, entryOverride: TrackerLog? = nil) {
    self.tracker = tracker
    self.entryOverride = entryOverride
  }

  var body: some View {
    HStack {
      let trackedForToday = isTrackerLoggedToday(tracker)
      Image(systemName: trackedForToday ? "checkmark.circle.fill" : "checkmark.circle")
        .imageScale(.large)
        .foregroundColor(trackedForToday ? .green : .primary)
        .onTapGesture(perform: markAsCompleted)

      NavigationSheetLink {
        TrackerDetailScreen(tracker)
      } label: {
        HStack {
          VStack(alignment: .leading) {
            Text(tracker.title!)
              .foregroundColor(.primary)
            if let entry = entryOverride ?? tracker.mostRecentLog {
              Text("\(entry.timestamp!, style: .date) at \(entry.timestamp!, style: .time)")
                .font(.caption)
                .foregroundColor(.gray)
            }
          }

          if let entry = entryOverride ?? tracker.mostRecentLog, isTrackerLoggedToday(tracker) {
            Spacer()

            NavigationSheetLink(buttonOnly: true) {
              NavigationView {
                TrackerEntryDetailScreen(tracker: tracker, log: entry)
              }
            } label: {
              Image(systemName: "bookmark.circle")
            }
          }
        }
      }
    }
    .swipeActions(edge: .leading) {
      Button(action: markAsCompleted) {
        Label("Done", systemImage: "checkmark")
      }
    }
    .if(tracker.showInTodayView) {
      $0.swipeActions(edge: .trailing) {
        Button(action: hideFromTodayView) {
          Label("Hide", systemImage: "eye.slash")
        }
      }
    }
  }

  private func markAsCompleted() {
    if let log = tracker.mostRecentLog, Calendar.current.isDateInToday(log.timestamp!) {
      viewContext.delete(log)
    } else {
      let newLog = TrackerLog(context: viewContext)
      newLog.timestamp = Date()
      tracker.addToLogs(newLog)
    }

    try! viewContext.save()
  }

  private func isTrackerLoggedToday(_ tracker: Tracker) -> Bool {
    tracker.mostRecentLog?.timestamp.map { Calendar.current.isDateInToday($0) } ?? false
  }

  private func hideFromTodayView() {
    withAnimation {
      tracker.showInTodayView = false
      try! viewContext.save()
    }
  }
}
