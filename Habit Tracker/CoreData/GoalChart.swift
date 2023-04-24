//
//  GoalChart.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 2/24/23.
//

import Foundation

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

enum ChartDate: Int16, CaseIterable, Identifiable {
  case start, end, both

  var id: Int16 { self.rawValue }

  var stringValue: String {
    switch self {
    case .start:
      return "Start"
    case .end:
      return "End"
    case .both:
      return "Both"
    }
  }
}

extension GoalChart {
  // TODO: Use name override for chart name
//  @objc var name: String {
//    nameOverride ?? tracker?.tracker?.title ?? ""
//  }

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

  var logDate: ChartDate {
    get {
      ChartDate(rawValue: dateRawValue)!
    }
    set {
      dateRawValue = newValue.rawValue
    }
  }

  var allAnnotations: [GoalChartAnnotation] {
    annotations?.allManagedObjects() ?? []
  }
}
