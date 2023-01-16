//
//  GoalDetailsHabitsScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/16/23.
//

import SwiftUI

struct GoalDetailsHabitsScreen: View {
  @ObservedObject var goal: Goal

  @FetchRequest
  private var habitCriterias: FetchedResults<GoalHabitCriteria>

  @State private var isShowingAddHabitPicker = false

  @Environment(\.managedObjectContext)
  private var viewContext

  init(_ goal: Goal) {
    self.goal = goal
    self._habitCriterias = FetchRequest(
      sortDescriptors: [SortDescriptor(\GoalHabitCriteria.habit!.title)],
      predicate: NSPredicate(format: "goal = %@", goal)
    )
  }

  var body: some View {
    NavigationView {
      List {
        Section("Habits") {
          ForEach(habitCriterias.map(\.habit!)) { habit in
            Text(habit.title!)
              .swipeActions {
                Button {
                  withAnimation {
                    viewContext.delete(habit)
                    try! viewContext.save()
                  }
                } label: {
                  Text("Remove")
                }
              }
          }
        }
      }
      .toolbar {
        Menu {
          Button(action: { isShowingAddHabitPicker = true }, label: {
            Label("Add Habit", systemImage: "text.book.closed")
          })
        } label: {
          Image(systemName: "ellipsis")
        }
      }
      .navigationTitle(goal.title!)
    }
    .sheet(isPresented: $isShowingAddHabitPicker) {
      HabitPickerScreen(title: "Select Habit to Add", subtitle: goal.title!, didPick: { habit in
        isShowingAddHabitPicker = false

        let newHabit = GoalHabitCriteria(context: viewContext)
        newHabit.habit = habit
        newHabit.goal = goal

        goal.addToHabits(newHabit)

        try! viewContext.save()
      }, disabled: { habit in
        habitCriterias.map(\.habit).contains(where: { $0 == habit })
      })
    }
  }

  private func removeHabitFromGoal(indexes: IndexSet) {
    withAnimation {
      let habitToRemove = habitCriterias[indexes.first!]
      viewContext.delete(habitToRemove)
      try! viewContext.save()
    }
  }
}
