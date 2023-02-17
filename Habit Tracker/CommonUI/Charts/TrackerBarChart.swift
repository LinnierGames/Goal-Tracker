//
//  TrackerChart.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/21/23.
//

import Charts
import CoreData
import SwiftUI

struct TrackerBarChart: View, ChartTools {
  @ObservedObject var tracker: Tracker
  var range: ClosedRange<Date>

  enum Granularity {
    case hours, days, weeks, months
  }
  var granularity: DateWindow

  enum Width {
    case short, full
  }
  var width: Width

  private struct Data: Identifiable {
    var id: TimeInterval { timestamp.timeIntervalSince1970 }

    let timestamp: Date
    let count: Int
  }
  private var data: [Data]

  @Environment(\.managedObjectContext) private var viewContext

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

//    // TODO: support other granularities

    self.data = Self.strideChartMarks(range: range, granularity: granularity)
      .map { day, lowerBound, upperBound in
        let nEntriesForDay: Int = {
          let fetch = TrackerLog.fetchRequest()
          fetch.predicate = NSPredicate(
            format: "tracker = %@ AND timestamp >= %@ AND timestamp < %@",
            tracker, lowerBound as NSDate, upperBound as NSDate
          )

          guard let results = try? context.fetch(fetch) else {
            assertionFailure()
            return 0
          }

          return results.count
        }()

        return (timestamp: day, count: nEntriesForDay)
      }
      .map { timestamp, count in
        Data(timestamp: timestamp, count: count)
      }
  }

  var body: some View {
    Chart(data) { entry in
      switch granularity {
      case .day:
        BarMark(x: .value("Date", entry.timestamp, unit: .hour), y: .value("Count", entry.count))
      case .week, .month:
        BarMark(x: .value("Date", entry.timestamp, unit: .day), y: .value("Count", entry.count))
      case .year:
        BarMark(x: .value("Date", entry.timestamp, unit: .month), y: .value("Count", entry.count))
      }
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
