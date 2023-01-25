//
//  HabbitsScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/14/23.
//

import SwiftUI

struct HabitsScreen: View {
  @State private var newTrackerTitle = ""

  @Environment(\.managedObjectContext)
  private var viewContext

  @FetchRequest(sortDescriptors: [SortDescriptor(\Habit.title)])
  private var items: FetchedResults<Habit>

  var body: some View {
    NavigationView {
      List(items) { tracker in
        NavigationSheetLink {
          HabitDetailScreen(tracker)
        } label: {
          Text(tracker.title ?? "Untitled")
            .foregroundColor(.primary)
            .contextMenu {
              Button(action: { addLog(for: tracker) }, title: "Add log", systemImage: "plus")
            }
        }
      }
      .navigationTitle("Habits")
      .toolbar {
        AlertLink(title: "Add Tracker") {
          TextField("Title", text: $newTrackerTitle)
          Button("Cancel", role: .cancel, action: {})
          Button("Add", action: addNewTracker)
        } message: {
          Text("enter the title for your new tracker")
        } label: {
          Image(systemName: "plus")
        }
      }
    }
  }

  private func addNewTracker() {
    let newTracker = Habit(context: viewContext)
    newTracker.title = newTrackerTitle
    try! viewContext.save()

    newTrackerTitle = ""
  }

  private func addLog(for tracker: Habit) {
    let newLog = HabitEntry(context: viewContext)
    newLog.timestamp = Date()
    tracker.addToEntries(newLog)

    try! viewContext.save()
  }
}
