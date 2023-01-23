//
//  HabbitsScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/14/23.
//

import SwiftUI

struct HabitsScreen: View {
  @Environment(\.managedObjectContext) private var viewContext

  @FetchRequest(sortDescriptors: [SortDescriptor(\Habit.title)])
  private var items: FetchedResults<Habit>

  var body: some View {
    NavigationView {
      List(items) { tracker in
        SheetLink {
          HabitDetailScreen(tracker)
        } label: {
          HStack {
            Text(tracker.title ?? "Untitled")
            Spacer()
            Image(systemName: "chevron.right")
          }
          .foregroundColor(.primary)
          .contextMenu {
            Button(action: { addLog(for: tracker) }, title: "Add log", systemImage: "plus")
          }
        }
      }
      .navigationTitle("Habits")
      .toolbar {
        Button(action: addNewTracker) {
          Image(systemName: "plus")
        }
      }
    }
  }

  private func addNewTracker() {
    let newTracker = Habit(context: viewContext)
    newTracker.title = "_ A new tracker"
    try! viewContext.save()
  }

  private func addLog(for tracker: Habit) {
    let newLog = HabitEntry(context: viewContext)
    newLog.timestamp = Date()
    tracker.addToEntries(newLog)

    try! viewContext.save()
  }
}
