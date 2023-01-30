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

enum ChartKind: Int16, CaseIterable, Identifiable {
  case count
  case frequency

  var id: Int16 { self.rawValue }

  var stringValue: String {
    switch self {
    case .count:
      return "Count"
    case .frequency:
      return "Frequency"
    }
  }
}

enum ChartSize: Int16, CaseIterable, Identifiable {
  case small, medium, large, extraLarge

  var id: Int16 { self.rawValue }

  var stringValue: String {
    switch self {
    case .small:
      return "Small"
    case .medium:
      return "Medium"
    case .large:
      return "Large"
    case .extraLarge:
      return "Extra Large"
    }
  }

  var floatValue: CGFloat {
    switch self {
    case .small:
      return 48
    case .medium:
      return 64
    case .large:
      return 96
    case .extraLarge:
      return 132
    }
  }
}

extension GoalChart {
  var kind: ChartKind {
    get {
      ChartKind(rawValue: kindRawValue)!
    }
    set {
      kindRawValue = newValue.rawValue
    }
  }

  var height: ChartSize {
    get {
      ChartSize(rawValue: heightRawValue)!
    }
    set {
      heightRawValue = newValue.rawValue
    }
  }
}
