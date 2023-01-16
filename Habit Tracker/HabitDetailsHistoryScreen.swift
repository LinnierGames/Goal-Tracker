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
  var entries: FetchedResults<HabitEntry>

  init(habit: Habit) {
    self.habit = habit
    self._entries = FetchRequest(
      sortDescriptors: [SortDescriptor(\HabitEntry.timestamp)],
      predicate: NSPredicate(format: "habit = %@", habit)
    )
  }

  var body: some View {
    NavigationView {
      List {
        Section("Entries") {
          ForEach(entries) { entry in
            Text("\(entry.timestamp!, style: .date) at \(entry.timestamp!, style: .time)")
          }
        }
      }
      .navigationBarTitleDisplayMode(.large)
      .navigationTitle(habit.title!)
    }
  }
}
