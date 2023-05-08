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
    ForEach(log) { log in
      label(log)
    }
  }
}
