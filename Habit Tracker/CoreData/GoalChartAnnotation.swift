//
//  GoalChartAnnotation.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 4/23/23.
//

import CoreData

enum GoalChartAnnotationKind: Int16, CaseIterable, Identifiable {
  case line
  case point

  var id: Int16 { self.rawValue }

  var stringValue: String {
    switch self {
    case .line:
      return "Line"
    case .point:
      return "Point"
    }
  }
}

extension GoalChartAnnotation {
  var kind: GoalChartAnnotationKind {
    get {
      GoalChartAnnotationKind(rawValue: kindRawValue)!
    }
    set {
      kindRawValue = newValue.rawValue
    }
  }
}
