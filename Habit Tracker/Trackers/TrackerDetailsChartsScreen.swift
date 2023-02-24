//
//  TrackerDetailsChartsScreen.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/15/23.
//

import Charts
import MetricKit
import SwiftUI

struct TrackerDetailsChartScreen: View {
  let dateRange: Date
  let dateRangeWindow: DateWindow

  @ObservedObject var tracker: Tracker

  @StateObject private var datePickerViewModel: DateRangePickerViewModel

  @FetchRequest
  private var entries: FetchedResults<TrackerLog>

  @Environment(\.managedObjectContext)
  private var viewContext

  @EnvironmentObject
  private var sync: ExternalSyncManager

  init(_ tracker: Tracker, dateRange: Date = Date(), dateRangeWindow: DateWindow = .week) {
    self.dateRange = dateRange
    self.dateRangeWindow = dateRangeWindow
    self.tracker = tracker
    self._datePickerViewModel =
      StateObject(wrappedValue: DateRangePickerViewModel(intialDate: dateRange, intialWindow: dateRangeWindow))
    self._entries = FetchRequest(
      sortDescriptors: [SortDescriptor(\TrackerLog.timestamp)],
      predicate: NSPredicate(format: "tracker = %@", tracker)
    )
  }

  var body: some View {
    NavigationView {
      VStack {
        DateRangePicker(viewModel: datePickerViewModel)

        // Charts
        VStack {
          TrackerBarChart(
            tracker,
            range: datePickerViewModel.startDate...datePickerViewModel.endDate,
            granularity: datePickerViewModel.selectedDateWindow,
            context: viewContext
          ).frame(height: 196)
          TrackerPlotChart(
            tracker,
            range: datePickerViewModel.startDate...datePickerViewModel.endDate,
            logDate: .both,
            granularity: datePickerViewModel.selectedDateWindow,
            context: viewContext
          ).frame(height: 196)
        }

        Spacer()
      }
      .padding(.horizontal)

      .navigationTitle(tracker.title!)

      .onAppear {
        sync.syncDateRange(tracker: tracker, range: datePickerViewModel.startDate...datePickerViewModel.endDate)
      }
      .onReceive(datePickerViewModel.didUpdateRange) { _, range in
        sync.syncDateRange(tracker: tracker, range: range)
      }
    }
  }

  private struct Data: Identifiable {
    var id: String { timestamp }

    let timestamp: String
    let count: Int
  }

  private func makeDayView() -> some View {
    let hour = TimeInterval(hours: 1)
    let data = stride(
      from: datePickerViewModel.startDate.midnight,
      to: datePickerViewModel.endDate.midnight,
      by: hour
    )
    .map { day in
      let nEntriesForDay: Int = {
        let lowerBound = day.set(minute: 0)
        let upperBound = day.set(minute: 0).addingTimeInterval(.init(hours: 1))
        let fetch = TrackerLog.fetchRequest()
        fetch.predicate = NSPredicate(
          format: "tracker = %@ AND timestamp >= %@ AND timestamp < %@",
          tracker, lowerBound as NSDate, upperBound as NSDate
        )

        guard let results = try? viewContext.fetch(fetch) else {
          assertionFailure()
          return 0
        }

        return results.count
      }()

      let formatter = DateFormatter()
      formatter.dateFormat = "H"
      let bucket = formatter.string(from: day)

      return (timestamp: bucket, count: nEntriesForDay)
    }
    .map { timestamp, count in
      Data(timestamp: timestamp, count: count)
    }

    return Chart(data) { entry in
      BarMark(x: .value("Date", entry.timestamp), y: .value("TimeInterval", entry.count))
    }
  }

  private func makeWeekView() -> some View {
    TrackerBarChart(
      tracker,
      range: datePickerViewModel.startDate...datePickerViewModel.endDate,
      granularity: .week,
      context: viewContext
    )
  }

  private func makeMonthView() -> some View {
    let day: TimeInterval = 60*60*24
    let data = stride(
      from: datePickerViewModel.startDate,
      to: datePickerViewModel.endDate,
      by: day
    )
    .map { day in
      let nEntriesForDay: Int = {
        let fetch = TrackerLog.fetchRequest()
        fetch.predicate = NSPredicate(
          format: "tracker = %@ AND timestamp >= %@ AND timestamp < %@",
          tracker, day.midnight as NSDate,
          day.addingTimeInterval(.init(days: 1)).midnight as NSDate
        )

        guard let results = try? viewContext.fetch(fetch) else {
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

    return Chart(data) { entry in
      BarMark(x: .value("Date", entry.timestamp), y: .value("TimeInterval", entry.count))
    }
  }

  private func makeYearView() -> some View {
    Text("makeYearView")
  }

}
