//
//  MostRecentLog.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 5/8/23.
//

import SwiftUI

struct MostRecentLog<Content: View>: View {
  @ObservedObject var tracker: Tracker

  let label: (TrackerLog) -> Content

  @FetchRequest
  private var log: FetchedResults<TrackerLog>

  init(tracker: Tracker, isToday: Bool = false, @ViewBuilder label: @escaping (TrackerLog) -> Content) {
    self.tracker = tracker
    let mostRecentLog = TrackerLog.fetchRequest()
    mostRecentLog.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerLog.timestamp, ascending: false)]
    mostRecentLog.fetchLimit = 1
    if isToday {
      let midnight = Date().midnight
      let tomorrow = midnight.addingTimeInterval(.init(days: 1))
      mostRecentLog.predicate = NSPredicate(
        format: "tracker = %@ AND timestamp >= %@ AND timestamp < %@",
        tracker, midnight as NSDate, tomorrow as NSDate
      )
    } else {
      mostRecentLog.predicate = NSPredicate(format: "tracker = %@", tracker)
    }

    self._log = FetchRequest(fetchRequest: mostRecentLog)
    self.label = label
  }

  var body: some View {
    ForEach(log.prefix(1)) { log in
      label(log)
    }
  }
}

/// Provide logs for the given tracker and predicate and display its `label`
struct TrackerLogView<Content: View>: View {
  @ObservedObject var tracker: Tracker

  let label: (FetchedResults<TrackerLog>) -> Content

  @FetchRequest
  private var logs: FetchedResults<TrackerLog>

  init(tracker: Tracker, date: Date, @ViewBuilder label: @escaping (FetchedResults<TrackerLog>) -> Content) {
    self.tracker = tracker
    let fetch = TrackerLog.fetchRequest()
    fetch.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerLog.timestamp, ascending: false)]
    let midnight = date.midnight
    let tomorrow = midnight.addingTimeInterval(.init(days: 1))
    fetch.predicate = NSPredicate(
      format: "tracker = %@ AND timestamp >= %@ AND timestamp < %@",
      tracker, midnight as NSDate, tomorrow as NSDate
    )

    self._logs = FetchRequest(fetchRequest: fetch)
    self.label = label
  }

  init(predicate: NSPredicate) {
    fatalError()
  }

  var body: some View {
    label(logs)
  }
}

extension TrackerLogView where Content == EmptyView {
  static func thisWeeks(tracker: Tracker) -> some View {
    ThisWeeksTrackerLogView(tracker: tracker, window: .week)
  }

  static func dateRange(tracker: Tracker, window: DateWindow) -> some View {
    ThisWeeksTrackerLogView(tracker: tracker, window: window)
  }
}

private struct ThisWeeksTrackerLogView: View {
  @ObservedObject var tracker: Tracker
  private let dates: [Date]

  init(tracker: Tracker, window: DateWindow) {
    self._tracker = ObservedObject(initialValue: tracker)

    let now = Date()
    let start: Date
    let calendar = Calendar.current
    switch window {
    case .day:
      start = now.midnight
    case .week:
      let sunday = calendar.date(
        from: calendar.dateComponents(
          [.yearForWeekOfYear, .weekOfYear],
          from: now
        )
      )

      start = calendar.date(byAdding: .day, value: 0, to: sunday!)!
    case .month:
      start = now.set(day: 1)
    case .year:
      start = now.set(day: 1, month: 1)
    }

    let end: Date
    switch window {
    case .day:
      end = calendar.date(byAdding: .day, value: 1, to: start)!
    case .week:
      end = calendar.date(byAdding: .weekOfYear, value: 1, to: start)!
    case .month:
      end = calendar.date(byAdding: .month, value: 1, to: start)!
    case .year:
      end = calendar.date(byAdding: .year, value: 1, to: start)!
    }

    let step: TimeInterval
    if window == .day {
      step = .init(hours: 1)
    } else {
      step = .init(days: 1)
    }

    self.dates = Array(stride(from: start, to: end, by: step))
  }

  var body: some View {
    HStack(spacing: -1) {
      ForEach(dates, id: \.timeIntervalSince1970) { date in
        TrackerLogView(tracker: tracker, date: date) { logs in
          if logs.isEmpty {
            if Calendar.current.isDateInToday(date) {
              Rectangle()
                .strokeBorder()
                .background(Color.blue.opacity(0.35))
                .frame(height: 16)
            } else {
              Rectangle()
                .strokeBorder()
                .frame(height: 16)
            }
          } else {
            if Calendar.current.isDateInToday(date) {
              Rectangle()
                .strokeBorder()
                .background(Color.green)
                .frame(height: 16)
            } else {
              Rectangle()
                .strokeBorder()
                .background(Color.green.opacity(0.35))
                .frame(height: 16)
            }
          }
        }
      }
    }
  }
}
