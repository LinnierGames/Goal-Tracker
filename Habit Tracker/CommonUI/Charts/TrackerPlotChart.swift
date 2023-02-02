//
//  TrackerPlotChart.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/26/23.
//

import Charts
import CoreData
import SwiftUI

struct TrackerPlotChart: View {
  @ObservedObject var tracker: Tracker
  var range: ClosedRange<Date>

  enum Granularity {
    case hours, days, weeks, months
  }
  var granularity: Granularity

  private struct Data: Identifiable {
    var id: TimeInterval { timestamp.timeIntervalSince1970 }

    let timestamp: Date
    let hour: Int
  }
  private var data: [Data]

  @Environment(\.managedObjectContext)
  private var viewContext

  init(
    _ tracker: Tracker,
    range: ClosedRange<Date>,
    granularity: Granularity,
    context: NSManagedObjectContext
  ) {
    self.tracker = tracker
    self.range = range
    self.granularity = granularity

    // TODO: support other granularities

    let day: TimeInterval = 60*60*24
    self.data = stride(from: range.lowerBound, to: range.upperBound, by: day)
      .map { day -> [(Date, Int)] in
        let entriesForDay: [TrackerLog] = {
          let fetch = TrackerLog.fetchRequest()
          fetch.predicate = NSPredicate(
            format: "tracker = %@ AND timestamp >= %@ AND timestamp < %@",
            tracker, day.midnight as NSDate,
            day.addingTimeInterval(.init(days: 1)).midnight as NSDate
          )

          guard let results = try? context.fetch(fetch) else {
            assertionFailure()
            return []
          }

          return results
        }()

        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        let bucket = Int(formatter.string(from: day)) ?? 1

        return entriesForDay.map { entry in
          let formatter = DateFormatter()
          formatter.dateFormat = "HH"
          let hour = formatter.string(from: entry.timestamp!)

          return Int(hour) ?? 0
        }.map { hour in
          (timestamp: day, hour: hour)
        }
      }
      .flatMap { $0 }
      .map { timestamp, hour in
        Data(timestamp: timestamp, hour: hour)
      }
  }

  var body: some View {
    Chart {
      ForEach(data) { entry in
        PointMark(x: .value("Date", entry.timestamp, unit: .day), y: .value("Hour", entry.hour))
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
        RectangleMark(
          xStart: .value("Date", self.range.lowerBound),
          xEnd: .value("Date", self.range.upperBound),
          yStart: .value("Hour", range.lowerBound),
          yEnd: .value("Hour", range.upperBound)
        )
        .foregroundStyle(color)
        .opacity(0.2)
      }

//      RuleMark(xStart: .value("Date", rangeInt.lowerBound), xEnd: .value("Date", rangeInt.upperBound), y: .value("Hour", 12))
//        .foregroundStyle(.red)
    }
    .chartYScale(domain: 0...24)
    .chartYAxis {
      AxisMarks(format: ChartHourFormat(), values: [6, 12, 18])
    }
    .chartXAxis {
      AxisMarks(format: ChartDayFormat(), values: Array(stride(from: range.lowerBound, to: range.upperBound, by: .init(days: 1))))
    }
  }
}