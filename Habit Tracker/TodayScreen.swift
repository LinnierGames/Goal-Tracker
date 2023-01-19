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
    sortDescriptors: [SortDescriptor(\Habit.title)],
    predicate: NSPredicate(format: "showInTodayView == YES")
  )
  private var trackers: FetchedResults<Habit>

  var body: some View {
    NavigationView {
      List(trackers) { tracker in
        TodayTrackerCell(tracker)
      }
      .navigationTitle("Today")
    }
  }
}

struct TodayTrackerCell: View {
  @ObservedObject var tracker: Habit

  @Environment(\.managedObjectContext) private var viewContext

  init(_ tracker: Habit) {
    self.tracker = tracker
  }

  var body: some View {
    HStack {
      let trackedForToday = tracker.mostRecentEntry?.timestamp.map { Calendar.current.isDateInToday($0) } ?? false
      Button(action: markAsCompleted, systemImage: trackedForToday ? "checkmark.circle.fill" : "circle")
        .foregroundColor(trackedForToday ? .green : .black)
      VStack(alignment: .leading) {
        Text(tracker.title!)
        if let entry = tracker.mostRecentEntry {
          Text("\(entry.timestamp!, style: .date) at \(entry.timestamp!, style: .time)")
            .font(.caption)
            .foregroundColor(.gray)
        }
      }

      Spacer()

      SheetLink {
        HabitDetailScreen(tracker)
      } label: {
        Image(systemName: "info.circle")
          .foregroundColor(.accentColor)
      }
    }
    .swipeActions(edge: .leading) {
      Button(action: markAsCompleted) {
        Label("Done", systemImage: "checkmark")
      }
    }
    .swipeActions(edge: .trailing) {
      Button(action: hideFromTodayView) {
        Label("Hide", systemImage: "eye.slash")
      }
    }
  }

  private func markAsCompleted() {
    let newEntry = HabitEntry(context: viewContext)
    newEntry.timestamp = Date()
    tracker.addToEntries(newEntry)

    try! viewContext.save()
  }

  private func hideFromTodayView() {
    withAnimation {
      tracker.showInTodayView = false
      try! viewContext.save()
    }
  }
}
