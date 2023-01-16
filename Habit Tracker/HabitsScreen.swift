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
      List(items) { habit in
        SheetLink {
          HabitDetailScreen(habit)
        } label: {
          HStack {
            VStack(alignment: .leading) {
              Text(habit.title ?? "Untitled")
              Text(habit.entries?.allObjects.count ?? 0, format: .number)
            }
            Spacer()
            Image(systemName: "chevron.right")
          }
        }
      }
      .navigationTitle("Habits")
    }
  }
}
