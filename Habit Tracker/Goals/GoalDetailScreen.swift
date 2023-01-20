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

  init(_ goal: Goal) {
    self.goal = goal
  }

  var body: some View {
    TabView {
      GoalDetailsChartsScreen(goal)
        .tabItem {
          Label("Charts", systemImage: "chart.xyaxis.line")
        }

      GoalDetailsHabitsScreen(goal)
        .tabItem {
          Label("Habits", systemImage: "text.book.closed")
        }
    }
  }
}
