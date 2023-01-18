//
//  HabitDetailsHistoryScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/15/23.
//

import CoreData
import SwiftUI

struct HabitDetailsHistoryScreen: View {
  @ObservedObject var habit: Habit

  @FetchRequest
  private var entries: FetchedResults<HabitEntry>

  @Environment(\.managedObjectContext) private var viewContext

  init(_ habit: Habit) {
    self.habit = habit
    self._entries = FetchRequest(
      sortDescriptors: [SortDescriptor(\HabitEntry.timestamp)],
      predicate: NSPredicate(format: "habit = %@", habit)
    )
  }

  var body: some View {
    NavigationView {
      List {
        ForEach(entries) { entry in
          Text("\(entry.timestamp!, style: .date) at \(entry.timestamp!, style: .time)")
        }
        .onDelete(perform: deleteEntry)
      }
      .navigationBarTitleDisplayMode(.large)
      .navigationTitle(habit.title!)
    }
  }

  private func deleteEntry(indexes: IndexSet) {
    withAnimation {
      viewContext.delete(entries[indexes.first!])
      try! viewContext.save()
    }
  }
}
