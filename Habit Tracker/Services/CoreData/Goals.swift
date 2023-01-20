//
//  Goal.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/19/23.
//

import Foundation

extension Goal {
  var allHabits: [GoalHabitCriteria] {
    habits?.allManagedObjects() ?? []
  }

  var allChartSections: [GoalChartSection] {
    chartSections?.allManagedObjects() ?? []
  }
}

extension GoalChartSection {
  var allCharts: [GoalChart] {
    charts?.allManagedObjects() ?? []
  }
}
