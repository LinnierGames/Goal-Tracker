//
//  TodayScreen.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/17/23.
//

import Combine
import CoreData
import Rankable
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
      // `refreshAllObjects` only refreshes objects from which the cache is invalid. With a staleness interval of -1 the cache never invalidates.
      // We set the `stalenessInterval` to 0 to make sure that changes in the app extension get processed correctly.
      viewContext.stalenessInterval = 0
      viewContext.refreshAllObjects()
      viewContext.stalenessInterval = -1
    }

    self.objectWillChange.send()

    return // This didn't help
    PersistenceController.shared.container.performBackgroundTask { child in
      child.performAndWait {
        // `refreshAllObjects` only refreshes objects from which the cache is invalid. With a staleness interval of -1 the cache never invalidates.
        // We set the `stalenessInterval` to 0 to make sure that changes in the app extension get processed correctly.
        child.stalenessInterval = 0
        child.refreshAllObjects()
        child.stalenessInterval = -1
      }

      try! child.save()

      DispatchQueue.main.async {
        self.objectWillChange.send()
      }
    }
  }
}

struct TodayScreen: View {
  @StateObject private var viewModel = ViewModel()
  @Environment(\.managedObjectContext) private var viewContext

  @FetchRequest(
    sortDescriptors: [SortDescriptor(\Tracker.todayViewRank)],
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
        .onMove(perform: { indices, newOffset in
          guard let source = indices.first else { return }

          Rankable.moveElement(
            source: source,
            destination: newOffset > source ? newOffset - 1 : newOffset,
            elements: trackers
          )

          try! viewContext.save()
        })

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
        ToolbarItem(placement: .topBarTrailing) {
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
        HStack {
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

          actionButton()
        }
      }
    }
    .swipeActions(edge: .leading) {
      Button(action: markAsCompleted) {
        Label("Done", systemImage: "checkmark")
      }
    }
    .contextMenu {
      Button(action: addLog, title: "Add Log", systemImage: "plus")
    } preview: {
      VStack(alignment: .leading) {
        Text(tracker.title ?? "Untitled")
          .font(.title)
        Text(tracker.notes ?? "")

        VStack {
          let startOfYear = Date().set(day: 1, month: 1)
          let endOfYear = Date().set(day: 31, month: 12)
          TrackerBarChart(
            tracker,
            range: startOfYear...endOfYear,
            granularity: .year,
            width: .short,
            context: viewContext
          ).frame(height: 196)
          TrackerPlotChart(
            tracker,
            range: startOfYear...endOfYear,
            logDate: .both,
            granularity: .year,
            width: .short,
            annotations: [],
            context: viewContext
          ).frame(height: 196)
        }
      }
      .frame(maxWidth: .infinity)
      .frame(height: 600)
    }
  }

  @ViewBuilder
  private func actionButton() -> some View {
    Button {
      markAsCompleted()
    } label: {
      if isTrackerLoggedToday(tracker) {
        RoundedRectangle(cornerRadius: 4)
          .foregroundStyle(.green)
          .frame(width: 48, height: 48)
          .overlay(
            Image(systemName: "checkmark")
              .foregroundStyle(.white)
          )
      } else {
        RoundedRectangle(cornerRadius: 4)
          .stroke(.gray, lineWidth: 0.5)
          .frame(width: 48, height: 48)
      }
    }
    .buttonStyle(.borderless)
  }


  @ViewBuilder
  private func mostRecentLog() -> some View {
    if let entryOverride {
      NavigationSheetLink(buttonOnly: true) {
        NavigationView {
          TrackerLogDetailScreen(tracker: tracker, log: entryOverride)
        }
      } label: {
        Text(entryOverride.timestamp!, style: .time)
          .font(.caption)
          .foregroundColor(.gray)
          .padding(.vertical, 4)
          .padding(.horizontal, 8)
          .background(Capsule().stroke(Color.gray))
      }
    } else {
      MostRecentLog(tracker: tracker) { log in
        if isTrackerLoggedToday(tracker) {
          NavigationSheetLink(buttonOnly: true) {
            NavigationView {
              TrackerLogDetailScreen(tracker: tracker, log: log)
            }
          } label: {
            Text(log.timestamp!, style: .time)
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

extension Tracker: RankableObject {
  public var rank: Int {
    get { Int(todayViewRank) }
    set { todayViewRank = Int16(newValue) }
  }
}
