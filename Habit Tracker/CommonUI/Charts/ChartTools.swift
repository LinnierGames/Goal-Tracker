//
//  ChartTools.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 2/9/23.
//

import Foundation

protocol ChartTools {
}

extension ChartTools {
  static func strideChartMarks(range: ClosedRange<Date>, granularity: DateWindow) -> [(date: Date, upper: Date, lower: Date)] {
    switch granularity {
    case .day:
      return Swift.stride(
        from: range.lowerBound,
        to: range.upperBound,
        by: .init(hours: 1)
      ).map { day -> (Date, Date, Date) in
        let lowerBound = day.set(minute: 0)
        let upperBound = day.set(minute: 0).addingTimeInterval(.init(hours: 1))
        return (day, lowerBound, upperBound)
      }
    case .week, .month, .year: // TODO: support month and year
      return Swift.stride(
        from: range.lowerBound,
        to: range.upperBound,
        by: .init(days: 1)
      ).map { day -> (Date, Date, Date) in
        let lowerBound = day.midnight
        let upperBound = day.addingTimeInterval(.init(days: 1)).midnight
        return (day, lowerBound, upperBound)
      }
    }
  }

  static func strideDates(range: ClosedRange<Date>, granularity: DateWindow) -> [Date] {
    switch granularity {
    case .day:
      return Array(stride(from: range.lowerBound, to: range.upperBound, by: .init(hours: 6)))
    case .week:
      return Array(stride(from: range.lowerBound, to: range.upperBound, by: .init(days: 1)))
    case .month, .year: // TODO: support year
      return Array(stride(from: range.lowerBound, to: range.upperBound, by: .init(days: 7)))
    }
  }
}
