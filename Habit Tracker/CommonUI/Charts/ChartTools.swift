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
    case .week, .month: // TODO: support month and year
      return Swift.stride(
        from: range.lowerBound,
        to: range.upperBound,
        by: .init(days: 1)
      ).map { day -> (Date, Date, Date) in
        let lowerBound = day.midnight
        let upperBound = day.addingTimeInterval(.init(days: 1)).midnight
        return (day, lowerBound, upperBound)
      }
    case .year:
      let calendar = Calendar.current

//      calendar.range(of: .month, in: .year, for: range.lowerBound)


      return strideDates(range: range, granularity: granularity).map { month in
        let upperBound = calendar.date(byAdding: .month, value: 1, to: month)!
        return (month, month, upperBound)
      }



      let startOfYear = range.lowerBound.set(day: 1, month: 1)
      let f = (1...12).map { month in
        let day = startOfYear.set(month: month)

        let lowerBound = day.midnight
        let upperBound = calendar.date(byAdding: .month, value: 1, to: day)!
        return (day, day, upperBound)
      }

      return f
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
    case .month:
      return Array(stride(from: range.lowerBound, to: range.upperBound, by: .init(days: 7)))
    case .year:
      let calendar = Calendar.current
      guard let monthRange = calendar.range(of: .month, in: .year, for: range.lowerBound) else {
        return []
      }

      var components = calendar.dateComponents([.day, .month, .year, .era], from: range.lowerBound)

      let componentsForWholeYear = monthRange.compactMap { month in
        components.day = 1
        components.month = month
        return calendar.date(from: components)
      }

      return componentsForWholeYear
    }
  }
}
