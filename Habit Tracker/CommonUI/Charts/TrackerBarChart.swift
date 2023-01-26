//
//  TrackerChart.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/21/23.
//

import Charts
import CoreData
import SwiftUI

struct TrackerBarChart: View {
  @ObservedObject var tracker: Tracker
  var range: ClosedRange<Date>

  enum Granularity {
    case hours, days, weeks, months
  }
  var granularity: Granularity

  private struct Data: Identifiable {
    var id: String { timestamp }

    let timestamp: String
    let count: Int
  }
  private var data: [Data]

  @Environment(\.managedObjectContext) private var viewContext

  init(
    _ tracker: Tracker,
    range: ClosedRange<Date>,
    granularity: Granularity,
    context: NSManagedObjectContext
  ) {
    self.tracker = tracker
    self.range = range
    self.granularity = granularity

    let day: TimeInterval = 60*60*24
    self.data = stride(from: range.lowerBound, to: range.upperBound, by: day)
      .map { day in
        let nEntriesForDay: Int = {
          let fetch = TrackerLog.fetchRequest()
          fetch.predicate = NSPredicate(
            format: "tracker = %@ AND timestamp >= %@ AND timestamp < %@",
            tracker, day.midnight as NSDate,
            day.addingTimeInterval(.init(days: 1)).midnight as NSDate
          )

          guard let results = try? context.fetch(fetch) else {
            assertionFailure()
            return 0
          }

          return results.count
        }()

        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        let bucket = formatter.string(from: day)

        return (timestamp: bucket, count: nEntriesForDay)
      }
      .map { timestamp, count in
        Data(timestamp: timestamp, count: count)
      }
  }

  var body: some View {
    Chart(data) { entry in
      BarMark(x: .value("Date", entry.timestamp), y: .value("Count", entry.count))
    }
  }
}
