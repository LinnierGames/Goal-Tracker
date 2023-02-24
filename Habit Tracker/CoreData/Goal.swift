//
//  Goal.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/19/23.
//

import Foundation

extension Goal {
  var allTrackers: [GoalTrackerCriteria] {
    trackers?.allManagedObjects() ?? []
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
