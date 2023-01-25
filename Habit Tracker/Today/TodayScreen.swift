//
//  TodayScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/17/23.
//

import SwiftUI

struct TodayScreen: View {
  @Environment(\.managedObjectContext) private var viewContext

  @FetchRequest(
    sortDescriptors: [SortDescriptor(\Habit.title!)],
    predicate: NSPredicate(format: "showInTodayView == YES")
  )
  private var trackers: FetchedResults<Habit>

  @FetchRequest(
    sortDescriptors: [SortDescriptor(\HabitEntry.habit!.title!)],
    predicate: NSPredicate(
      format: "timestamp >= %@ AND timestamp < %@ AND habit.showInTodayView == NO",
      Date().midnight as NSDate,
      Date().addingTimeInterval(.init(days: 1)).midnight as NSDate
    )
  )
  private var entriesLoggedToday: FetchedResults<HabitEntry>

  var body: some View {
    NavigationView {
      List {
        ForEach(trackers) { tracker in
          TodayTrackerCell(tracker)
        }

        if !entriesLoggedToday.isEmpty {
          Section("Other Trackers") {
            // TODO: Remove duplicate trackers
            ForEach(entriesLoggedToday.map(\.habit!)) { tracker in
              TodayTrackerCell(tracker)
            }
          }
        }
      }
      .navigationTitle("Today")
    }
  }
}

struct TodayTrackerCell: View {
  @ObservedObject var tracker: Habit

  @Environment(\.managedObjectContext)
  private var viewContext

  init(_ tracker: Habit) {
    self.tracker = tracker
  }

  var body: some View {
    HStack {
      let trackedForToday = isTrackerLoggedToday(tracker)
      Image(systemName: trackedForToday ? "checkmark.circle.fill" : "checkmark.circle")
        .imageScale(.large)
        .foregroundColor(trackedForToday ? .green : .primary)
        .onTapGesture(perform: markAsCompleted)

      NavigationSheetLink {
        HabitDetailScreen(tracker)
      } label: {
        VStack(alignment: .leading) {
          Text(tracker.title!)
            .foregroundColor(.primary)
          if let entry = tracker.mostRecentEntry {
            Text("\(entry.timestamp!, style: .date) at \(entry.timestamp!, style: .time)")
              .font(.caption)
              .foregroundColor(.gray)
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
    if let log = tracker.mostRecentEntry, Calendar.current.isDateInToday(log.timestamp!) {
      viewContext.delete(log)
    } else {
      let newEntry = HabitEntry(context: viewContext)
      newEntry.timestamp = Date()
      tracker.addToEntries(newEntry)
    }

    try! viewContext.save()
  }

  private func isTrackerLoggedToday(_ tracker: Habit) -> Bool {
    tracker.mostRecentEntry?.timestamp.map { Calendar.current.isDateInToday($0) } ?? false
  }

  private func hideFromTodayView() {
    withAnimation {
      tracker.showInTodayView = false
      try! viewContext.save()
    }
  }
}
