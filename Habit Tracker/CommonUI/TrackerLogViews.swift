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
    ThisWeeksTrackerLogView(tracker: tracker)
  }
}

private struct ThisWeeksTrackerLogView: View {
  @ObservedObject var tracker: Tracker
  private let dates: [Date]

  init(tracker: Tracker) {
    self._tracker = ObservedObject(initialValue: tracker)
    let startOfWeek = Date().startOfWeek
    self.dates = Array(stride(from: startOfWeek, to: startOfWeek.addingTimeInterval(.init(days: 7)), by: .init(days: 1)))
  }

  var body: some View {
    HStack(spacing: -1) {
      ForEach(dates, id: \.timeIntervalSince1970) { date in
        TrackerLogView(tracker: tracker, date: date) { logs in
          if logs.isEmpty {
            Rectangle()
              .strokeBorder()
              .frame(height: 16)
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
