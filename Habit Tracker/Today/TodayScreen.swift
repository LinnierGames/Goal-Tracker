//
//  TodayScreen.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/17/23.
//

import Combine
import SwiftUI

private class ViewModel: ObservableObject {
  private var bag = Set<AnyCancellable>()

  init() {
    NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
      .map { _ in }
      .sink(receiveValue: { [weak self] _ in self?.viewContextDidSaveExternally() })
      .store(in: &bag)
  }

  /// Called when a certain managed object context has been saved from an external process. It should also be called on the context's queue.
  func viewContextDidSaveExternally() {
    let viewContext = PersistenceController.shared.container.viewContext
    viewContext.perform {
      // `refreshAllObjects` only refreshes objects from which the cache is invalid. With a staleness intervall of -1 the cache never invalidates.
      // We set the `stalenessInterval` to 0 to make sure that changes in the app extension get processed correctly.
      viewContext.stalenessInterval = 0
      viewContext.refreshAllObjects()
      viewContext.stalenessInterval = -1

      self.objectWillChange.send()
    }
  }
}

struct TodayScreen: View {
  @StateObject private var viewModel = ViewModel()
  @Environment(\.managedObjectContext) private var viewContext

  @FetchRequest(
    sortDescriptors: [SortDescriptor(\Tracker.title!)],
    predicate: NSPredicate(format: "showInTodayView == YES")
  )
  private var trackers: FetchedResults<Tracker>

  @FetchRequest(
    sortDescriptors: [SortDescriptor(\TrackerLog.timestamp, order: .reverse)],
    predicate: NSPredicate(
      format: "timestamp >= %@ AND timestamp < %@ AND tracker.showInTodayView == NO",
      Date().midnight as NSDate,
      Date().addingTimeInterval(.init(days: 1)).midnight as NSDate
    )
  )
  private var logsForToday: FetchedResults<TrackerLog>

  private enum ViewStyle: String {
    case weekly, monthly, yealy

    var dateWindow: DateWindow {
      switch self {
      case .weekly:
        return .week
      case .monthly:
        return .month
      case .yealy:
        return .year
      }
    }
  }
  @AppStorage("TODAY_SCREEN_VIEW_STYLE") private var viewStyle = ViewStyle.weekly

  var body: some View {
    NavigationView {
      List {
        ForEach(trackers) { tracker in
          TodayTrackerCell(tracker, dateWindow: viewStyle.dateWindow)
        }

        if !logsForToday.isEmpty {
          Section("Other Trackers") {
            ForEach(logsForToday) { log in
              TodayTrackerCell(log.tracker!, dateWindow: viewStyle.dateWindow, entryOverride: log)
            }
          }
        }
      }
      .navigationTitle("Today")
      .toolbar {
        ToolbarItem {
          Picker("", selection: $viewStyle) {
            Text("W").tag(ViewStyle.weekly)
            Text("M").tag(ViewStyle.monthly)
            // TODO: Compute the year in Today view
//            Text("Y").tag(ViewStyle.yealy)
          }
          .pickerStyle(.segmented)
        }
      }
    }
  }
}

struct TodayTrackerCell: View {
  let entryOverride: TrackerLog?
  @ObservedObject var tracker: Tracker
  let dateWindow: DateWindow

  @Environment(\.managedObjectContext)
  private var viewContext

  init(_ tracker: Tracker, dateWindow: DateWindow, entryOverride: TrackerLog? = nil) {
    self.tracker = tracker
    self.dateWindow = dateWindow
    self.entryOverride = entryOverride
  }

  var body: some View {
    HStack {
//      let trackedForToday = isTrackerLoggedToday(tracker)
//      Image(systemName: trackedForToday ? "checkmark.circle.fill" : "checkmark.circle")
//        .imageScale(.large)
//        .foregroundColor(trackedForToday ? .green : .primary)
//        .onTapGesture(perform: markAsCompleted)

      NavigationSheetLink {
        TrackerDetailScreen(tracker)
      } label: {
        VStack {
          HStack {
            Text(tracker.title!)
              .lineLimit(1)
              .foregroundColor(.primary)

            Spacer()

            mostRecentLog()
          }

          TrackerLogView.dateRange(tracker: tracker, window: dateWindow)
        }
      }
    }
    .swipeActions(edge: .leading) {
      Button(action: markAsCompleted) {
        Label("Done", systemImage: "checkmark")
      }
    }
    .if(tracker.showInTodayView) {
      $0.swipeActions(edge: .trailing) {
        Button(action: hideFromTodayView) {
          Label("Hide", systemImage: "eye.slash")
        }
      }
    }
    .contextMenu {
      Button(action: addLog, title: "Add Log", systemImage: "plus")
    }
  }

  @ViewBuilder
  private func mostRecentLog() -> some View {
    if let entryOverride {
      HStack {
        Text("\(entryOverride.timestamp!, style: .time)")
          .font(.caption)
          .foregroundColor(.gray)

        NavigationSheetLink(buttonOnly: true) {
          NavigationView {
            TrackerLogDetailScreen(tracker: tracker, log: entryOverride)
          }
        } label: {
          Image(systemName: "bookmark.circle")
            .foregroundColor(.primary)
        }
      }
    } else {
      MostRecentLog(tracker: tracker) { log in
        if isTrackerLoggedToday(tracker) {
          NavigationSheetLink(buttonOnly: true) {
            NavigationView {
              TrackerLogDetailScreen(tracker: tracker, log: log)
            }
          } label: {
            Text("Today, \(log.timestamp!, style: .time)")
              .font(.caption)
              .foregroundColor(.gray)
              .padding(.vertical, 4)
              .padding(.horizontal, 8)
              .background(Capsule().stroke(Color.gray))
          }
        } else {
          Text(log.timestamp!.timeAgo)
            .font(.caption)
            .foregroundColor(.gray)
        }
      }
    }
  }

  private func markAsCompleted() {
    if let log = tracker.mostRecentLog, Calendar.current.isDateInToday(log.timestamp!) {
      viewContext.delete(log)
    } else {
      let newLog = TrackerLog(context: viewContext)
      newLog.timestamp = Date()
      tracker.addToLogs(newLog)
    }

    try! viewContext.save()
  }

  private func addLog() {
    let newLog = TrackerLog(context: viewContext)
    newLog.timestamp = Date()
    tracker.addToLogs(newLog)

    try! viewContext.save()
  }

  private func isTrackerLoggedToday(_ tracker: Tracker) -> Bool {
    tracker.mostRecentLog?.timestamp.map { Calendar.current.isDateInToday($0) } ?? false
  }

  private func hideFromTodayView() {
    withAnimation {
      tracker.showInTodayView = false
      try! viewContext.save()
    }
  }
}
