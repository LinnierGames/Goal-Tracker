//
//  GoalDetailsSettingsHabitsScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/16/23.
//

import SwiftUI

struct GoalDetailsSettingsHabitsScreen: View {
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
    List {
      Section("Habits") {
        ForEach(habitCriterias) { criteria in
          NavigationSheetLink {
            HabitDetailScreen(criteria.habit!)
          } label: {
            Text(criteria.habit!.title!)
          }
          .swipeActions {
            Button {
              withAnimation {
                viewContext.delete(criteria)
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
      SheetLink {
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
      } label: {
        Image(systemName: "plus")
      }
    }
    .navigationTitle("Linked Habits")
  }

  private func removeHabitFromGoal(indexes: IndexSet) {
    withAnimation {
      let habitToRemove = habitCriterias[indexes.first!]
      viewContext.delete(habitToRemove)
      try! viewContext.save()
    }
  }
}
