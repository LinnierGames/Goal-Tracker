//
//  TrackerPlotChart.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/26/23.
//

import Charts
import CoreData
import SwiftUI

extension Double: Identifiable {
  public var id: Double { self }
}

struct TrackerPlotChart: View, ChartTools {
  @ObservedObject var tracker: Tracker
  var range: ClosedRange<Date>

  var granularity: DateWindow

  enum Width {
    case short, full
  }
  var width: Width

  private struct Data: Identifiable {
    var id: TimeInterval { timestamp.timeIntervalSince1970 }

    let timestamp: Date
    let hour: Double
    let hours: [Double]
  }
  private var data: [Data]

  @Environment(\.managedObjectContext)
  private var viewContext

  init(
    _ tracker: Tracker,
    range: ClosedRange<Date>,
    granularity: DateWindow, width: Width = .full,
    context: NSManagedObjectContext
  ) {
    self.tracker = tracker
    self.range = range
    self.granularity = granularity
    self.width = width

    self.data = Self.strideChartMarks(range: range, granularity: granularity)
      .map { day, lowerBound, upperBound -> [(Date, Double, [Double])] in
        let entriesForRange: [TrackerLog] = {
          let fetch = TrackerLog.fetchRequest()
          fetch.predicate = NSPredicate(
            format: "tracker = %@ AND timestamp >= %@ AND timestamp < %@",
            tracker, lowerBound as NSDate, upperBound as NSDate
          )

          guard let results = try? context.fetch(fetch) else {
            assertionFailure()
            return []
          }

          return results
        }()

        switch granularity {
        case .day, .week, .month:
          return entriesForRange.map { entry in
            let formatter = DateFormatter()
            formatter.dateFormat = "HH"
            let hour = formatter.string(from: entry.timestamp!)

            return Double(hour) ?? 0
          }.map { hour in
            (day, hour, [])
          }
        case .year:
          guard !entriesForRange.isEmpty else { return [] }
          let hours = entriesForRange
            .map { Calendar.current.dateComponents([.hour], from: $0.timestamp!).hour! }
            .map { Double($0) }
          let sum = hours
            .reduce(0, +)

          let count = entriesForRange.count

//          let distance =
//            upperBound.timeIntervalSinceReferenceDate - lowerBound.timeIntervalSinceReferenceDate
//          let halfTheDistance = distance / 2
//          let halfTheDistanceAfterTheLowerBound = lowerBound.addingTimeInterval(halfTheDistance)

          return [(day, Double(sum) / Double(count), hours)]
        }
      }
      .flatMap { $0 }
      .map { timestamp, hour, hours in
        Data(timestamp: timestamp, hour: hour, hours: hours)
      }
  }

  var body: some View {
    Chart {
      ForEach(data) { entry in
        switch granularity {
        case .day, .week, .month:
          PointMark(x: .value("Date", entry.timestamp, unit: .day), y: .value("Hour", entry.hour))
        case .year:
          let barHeight: Double = 0.2
          ForEach(entry.hours) { hour in
            BarMark(
              x: .value("Date", entry.timestamp, unit: .month),
              yStart: .value("Hour", hour + barHeight),
              yEnd: .value("Hour", hour - barHeight),
              width: 12
            )
            .opacity(0.4)
          }

          LineMark(x: .value("Date", entry.timestamp, unit: .month), y: .value("Hour", entry.hour))
            .symbol(BasicChartSymbolShape.circle)
        }
      }

      // Color the sections of the day
      ForEach(
        [
          (0...6, Color.gray),
          (6...12, Color.orange),
          (12...18, Color.yellow),
          (18...24, Color.gray)
        ],
        id: \.0
      ) { range, color in
        switch granularity {
        case .day, .week, .month:
          RectangleMark(
            xStart: .value("Date", self.range.lowerBound),
            xEnd: .value("Date", self.range.upperBound),
            yStart: .value("Hour", range.lowerBound),
            yEnd: .value("Hour", range.upperBound)
          )
          .foregroundStyle(color)
          .opacity(0.2)
        case .year:
          RectangleMark(
            xStart: .value("Date", self.range.lowerBound, unit: .year),
            xEnd: .value("Date", self.range.upperBound, unit: .year),
            yStart: .value("Hour", range.lowerBound),
            yEnd: .value("Hour", range.upperBound)
          )
          .foregroundStyle(color)
          .opacity(0.2)
        }
      }

//      RuleMark(xStart: .value("Date", rangeInt.lowerBound), xEnd: .value("Date", rangeInt.upperBound), y: .value("Hour", 12))
//        .foregroundStyle(.red)
    }
    .chartYScale(domain: 0...24)
    .chartYAxis {
      AxisMarks(format: ChartHourFormat(), values: [6, 12, 18])
    }
    .chartXAxis {
      switch granularity {
      case .day:
        AxisMarks(
          format: ChartDayFormat(.hourOfTheDay()),
          values: Self.strideDates(range: range, granularity: granularity)
        )
      case .week:
        AxisMarks(
          format: ChartDayFormat(.dayOfTheWeek),
          values: Self.strideDates(range: range, granularity: granularity)
        )
      case .month:
        AxisMarks(
          format: ChartDayFormat(.dayOfTheMonth),
          values: Self.strideDates(range: range, granularity: granularity)
        )
      case .year:
        AxisMarks(
          format: ChartDayFormat(.monthOfTheYear(style: width == .full ? .medium : .short)),
          values: Self.strideDates(range: range, granularity: granularity)
        )
      }
    }
  }
}
