//
//  GoalDetailScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/15/23.
//

import Charts
import SwiftUI

struct GoalDetailScreen: View {
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
      Section("Charts") {
        Chart {
          LineMark(x: .value("x", "12 pm"), y: .value("count", 5))
          LineMark(x: .value("x", "1"), y: .value("count", 8))
          LineMark(x: .value("x", "2"), y: .value("count", 15))
          LineMark(x: .value("x", "3"), y: .value("count", 2))
        }
        .padding(.vertical)

        Chart {
          BarMark(x: .value("x", "12 pm"), y: .value("count", 5))
          BarMark(x: .value("x", "1"), y: .value("count", 8))
          BarMark(x: .value("x", "2"), y: .value("count", 15))
          BarMark(x: .value("x", "3"), y: .value("count", 2))

          LineMark(x: .value("x", "12 pm"), y: .value("count", 4))
          LineMark(x: .value("x", "1"), y: .value("count", 3))
          LineMark(x: .value("x", "2"), y: .value("count", 9))
          LineMark(x: .value("x", "3"), y: .value("count", 12))
        }
        .padding(.vertical)
      }

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
        }.onDelete(perform: removeHabitFromGoal)
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
    .navigationBarTitleDisplayMode(.inline)

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
