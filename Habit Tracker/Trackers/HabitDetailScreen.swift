//
//  HabitDetailScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/15/23.
//

import SwiftUI

struct HabitDetailScreen: View {
  @StateObject var habit: Habit
  @State var uiTabarController: UITabBarController?

  init(_ habit: Habit) {
    self._habit = StateObject(wrappedValue: habit)
  }

  var body: some View {
    TabView {
      HabitDetailsChartScreen(habit)
        .tabItem {
          Label("Analytics", systemImage: "chart.xyaxis.line")
        }

      HabitDetailsHistoryScreen(habit)
        .tabItem {
          Label("History", systemImage: "clock.arrow.circlepath")
        }

      HabitDetailsSettingsScreen(habit)
        .tabItem {
          Label("Habit", systemImage: "figure.walk")
        }
    }
  }
}
