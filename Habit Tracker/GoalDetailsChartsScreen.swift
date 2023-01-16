//
//  GoalDetailsChartsScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/16/23.
//

import SwiftUI

struct GoalDetailsChartsScreen: View {
  @ObservedObject var goal: Goal

  @FetchRequest
  private var habitCriterias: FetchedResults<GoalHabitCriteria>

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
      }
      .navigationTitle(goal.title!)
    }
  }
}
