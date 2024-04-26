//
//  GoalDashboardsScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 12/9/23.
//

import SwiftUI

struct GoalDashboardsScreen: View {
  @Environment(\.dismiss) var dismiss
  @Environment(\.managedObjectContext) var viewContext

  @StateObject private var dateRange =
    DateRangePickerViewModel(intialDate: Date(), intialWindow: .week)

  var body: some View {
    NavigationView {
      VStack {
        DateRangePicker(viewModel: dateRange)
          .padding(.horizontal)

        Form {
          sleepSection
        }
      }
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Done", action: dismiss.callAsFunction)
        }
      }
      .navigationTitle("Dashboards")
      .navigationBarTitleDisplayMode(.inline)
    }
    .environmentObject(dateRange)
  }

  private var sleepSection: some View {
    Section {
      goToBed()
      getOutOfBed()
    } header: {
      Text("Sleep")
    }
  }

  func goToBed() -> some View {
    func matchesPredicate(logs: [TrackerLog]) -> TrackerLog? {
      for log in logs {
        guard let timestamp = log.timestamp else { continue }

        let components = Calendar.current.dateComponents([.hour, .minute], from: timestamp)
        let (hour, minute) = (components.hour ?? 0, components.minute ?? 0)

        // log.timestamp isBetween 10pm and 11:45pm
        if hour == 23, minute < 45 {
          return log
        } else if hour == 22 {
          return log
        }

        continue
      }

      return nil
    }

    return ATrackerView("Go To Bed") { tracker in
      DidCompleteChart(
        tracker: tracker,
        daily: { logs in
          if logs.isEmpty {
            return .gray.opacity(0.35)
          } else if let _ = matchesPredicate(logs: logs) {
            return .green
          } else {
            return .red.opacity(0.35)
          }
        }, label: { logs in
          if let log = matchesPredicate(logs: logs), let timestamp = log.timestamp {
            Text(timestamp, format: .time)
              .font(.system(size: 6))
          } else if let first = logs.first, let timestamp = first.timestamp {
            Text(timestamp, format: .time)
              .font(.system(size: 6))
          } else {
            EmptyView()
          }
        }
      )
    }
  }

  func getOutOfBed() -> some View {
    func matchesPredicate(logs: [TrackerLog]) -> TrackerLog? {
      for log in logs {
        guard let timestamp = log.timestamp else { continue }

        let components = Calendar.current.dateComponents([.hour, .minute], from: timestamp)
        let (hour, minute) = (components.hour ?? 0, components.minute ?? 0)

        // log.timestamp isBetween 6am and 8:10am
        if hour == 8, minute < 10 {
          return log
        } else if hour == 6 || hour == 7 {
          return log
        }

        continue
      }

      return nil
    }

    return ATrackerView("Get Out Of Bed") { tracker in
      SheetLink {
        TrackerDetailScreen(tracker, dateRange: dateRange.selectedDate, dateRangeWindow: dateRange.selectedDateWindow)
      } label: {
        DidCompleteChart(
          tracker: tracker,
          daily: { logs in
            if logs.isEmpty {
              return .gray.opacity(0.35)
            } else if let _ = matchesPredicate(logs: logs) {
              return .green
            } else {
              return .red.opacity(0.35)
            }
          }, label: { logs in
            if let log = matchesPredicate(logs: logs), let timestamp = log.timestamp {
              Text(timestamp, format: .time)
                .font(.system(size: 6))
            } else if let first = logs.first, let timestamp = first.timestamp {
              Text(timestamp, format: .time)
                .font(.system(size: 6))
            } else {
              EmptyView()
            }
          }
        )
      }
    }
  }
}


/// Base view for all hardcoded tracker rows
struct ATrackerView<Label: View>: View {
  let tracker: String
  let label: (Tracker) -> Label

  init(_ tracker: String, label: @escaping (Tracker) -> Label) {
    self.tracker = tracker
    self.label = label
  }

  @EnvironmentObject var dateRange: DateRangePickerViewModel

  var body: some View {
    TrackerView(tracker) { tracker in
      SheetLink {
        TrackerDetailScreen(tracker, dateRange: dateRange.selectedDate, dateRangeWindow: dateRange.selectedDateWindow)
      } label: {
        VStack(alignment: .leading) {
          Text(self.tracker)
          label(tracker)
        }
      }
    }
  }
}

/// Color chart for the current window of the given tracker and predicate
struct DidCompleteChart<Label: View>: View {
  @ObservedObject var tracker: Tracker
  @EnvironmentObject var dateRange: DateRangePickerViewModel

  let daily: ([TrackerLog]) -> Color
  let label: ([TrackerLog]) -> Label

  init(
    tracker: Tracker,
    daily: @escaping ([TrackerLog]) -> Color,
    @ViewBuilder
    label: @escaping ([TrackerLog]) -> Label
  ) {
    self.tracker = tracker
    self.daily = daily
    self.label = label
  }

  var dates: [Date] {
    switch dateRange.selectedDateWindow {
    case .day:
      Array(stride(from: dateRange.startDate, to: dateRange.endDate, by: .init(hours: 1)))
    case .week, .month, .year:
      Array(stride(from: dateRange.startDate, to: dateRange.endDate, by: .init(days: 1)))
    }
  }

  var body: some View {
    HStack(spacing: -1) {
      ForEach(dates, id: \.timeIntervalSince1970) { date in
        TrackerLogView(tracker: tracker, date: date) { results in
          daily(Array(results))
            .border(Color.black)
            .overlay(label(Array(results)))
        }
      }
    }
  }
}

import CoreData

/// Find the `Tracker` given the hardcoded tracker name
struct TrackerView<Content: View>: View {
  let trackerName: String
  let content: (Tracker) -> Content
  @State private var tracker: Tracker?

  @Environment(\.managedObjectContext) var viewContext

  init(
    _ trackerName: String,
    @ViewBuilder content: @escaping (Tracker) -> Content
  ) {
    self.trackerName = trackerName
    self.content = content
  }

  var body: some View {
    Group {
      if let tracker {
        content(tracker)
      } else {
        Text("Tracker not found: \(trackerName)")
      }
    }.onAppear {
      do {
        let trackerByName = Tracker.fetchRequest()
        trackerByName.predicate = NSPredicate(format: "title == %@", trackerName)

        let result = try viewContext.fetch(trackerByName)

        if let tracker = result.first {
          self.tracker = tracker
        } else {
          self.tracker = nil
        }
      } catch {
        self.tracker = nil
      }
    }
  }
}
