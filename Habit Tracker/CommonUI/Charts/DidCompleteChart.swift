//
//  DidCompleteChart.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 4/28/24.
//

import SwiftUI

/// Color chart for the current window of the given tracker and predicate
struct DidCompleteChart<Label: View>: View {
  @ObservedObject var tracker: Tracker
  @EnvironmentObject var dateRange: DateRangePickerViewModel

  let daily: ([TrackerLog], Date) -> Color
  let monthly: (any Collection<TrackerLog>) -> (completed: Int, total: Int)
  let label: ([TrackerLog], Date) -> Label
  let negateColors: Bool

  init(
    tracker: Tracker,
    daily: @escaping ([TrackerLog], Date) -> Color,
    monthly: @escaping (any Collection<TrackerLog>) -> (completed: Int, total: Int),
    @ViewBuilder
    label: @escaping ([TrackerLog], Date) -> Label
  ) {
    self.tracker = tracker
    self.daily = daily
    self.monthly = monthly
    self.label = label
    self.negateColors = false
  }

  init(
    tracker: Tracker,
    negateColors: Bool = false
  ) where Label == AnyView {
    self.tracker = tracker
    self.daily = { logs, date in
      if logs.isEmpty {
        negateColors ? .green : .red
      } else {
        if logs.contains(where: { $0.completion == .complete }) {
          negateColors ? .red : .green
        } else if logs.contains(where: { $0.completion == .missed }) {
          negateColors ? .green : .red
        } else { // Skipped
          .gray
        }
      }
    }
    self.monthly = { logs in
      (logs.count, 30)
    }
    self.label = { logs,_ in
      Group {
        if logs.isEmpty {
          EmptyView()
        } else if logs.count > 1 {
          Text(logs.count, format: .number)
            .foregroundStyle(.white)
        } else {
          Group {
            if logs.contains(where: { $0.completion == .complete }) {
              if negateColors {
                Image(systemName: TrackerLogCompletion.complete.systemName)
                  .resizable()
              } else {
                EmptyView() // Hide labels for expected completion logs
              }
            } else if logs.contains(where: { $0.completion == .missed }) {
              if negateColors {
                EmptyView() // Hide labels for expected completion logs
              } else {
                Image(systemName: TrackerLogCompletion.missed.systemName)
                  .resizable()
              }
            } else { // Skipped
              Image(systemName: TrackerLogCompletion.skip.systemName)
                .resizable()
            }
          }
          .foregroundStyle(.white)
          .aspectRatio(contentMode: .fit)
          .frame(height: 10)
        }
      }.erasedToAnyView()
    }
    self.negateColors = negateColors
  }

  init(
    tracker: Tracker,
    negateColors: Bool = false,
    @ViewBuilder
    label: @escaping ([TrackerLog], Date) -> Label
  ) {
    self.tracker = tracker
    self.daily = { logs, date in
      if logs.isEmpty {
        negateColors ? .green : .red
      } else {
        if logs.contains(where: { $0.completion == .complete }) {
          negateColors ? .red : .green
        } else if logs.contains(where: { $0.completion == .missed }) {
          negateColors ? .green : .red
        } else { // Skipped
          .gray
        }
      }
    }
    self.monthly = { logs in
      (logs.count, 30)
    }
    self.label = label
    self.negateColors = negateColors
  }

  var dates: [Date] {
    switch dateRange.selectedDateWindow {
    case .day:
      Array(stride(from: dateRange.startDate, to: dateRange.endDate, by: .init(hours: 1)))
    case .week, .month:
      Array(stride(from: dateRange.startDate, to: dateRange.endDate, by: .init(days: 1)))
    case .year:
      Array(stride(from: dateRange.startDate, to: dateRange.endDate, by: .init(days: 30)))
    }
  }

  var body: some View {
    HStack(spacing: -1) {
      ForEach(dates, id: \.timeIntervalSince1970) { date in
        switch dateRange.selectedDateWindow {
        case .day, .week, .month:
          TrackerLogView(tracker: tracker, date: date) { results in
            if results.isEmpty, date >= Date().midnight {
              if Calendar.current.isDateInToday(date) {
                Color.blue.opacity(0.35)
                  .border(.white)
              } else if date > Date() {
                Color.clear
                  .border(.white)
              }
            } else {
              if results.isEmpty {
                daily([], date)
                  .overlay(label([], date))
                  .border(.white)
              } else if results.count == 1 {
                SheetLink {
                  NavigationStack {
                    TrackerLogDetailScreen(tracker: tracker, log: results[0])
                  }
                } label: {
                  daily(Array(results), date)
                    .overlay(label(Array(results), date))
                    .border(.white)
                }
                .buttonStyle(.borderless)
              } else {
                StateView(Optional<TrackerLog>.none) { selectedLog in
                  Menu {
                    ForEach(results) { log in
                      Button {
                        selectedLog.wrappedValue = log
                      } label: {
                        SwiftUI.Label(log.timestampFormat, systemImage: log.completion.systemName)
                      }
                    }
                  } label: {
                    daily(Array(results), date)
                      .overlay(label(Array(results), date))
                      .border(.white)
                  }
                  .menuStyle(.borderlessButton)
                  .sheet(item: selectedLog) { log in
                    NavigationStack {
                      TrackerLogDetailScreen(tracker: tracker, log: log)
                    }
                  }
                }
              }
            }
          }
        case .year:
          let endDate = Calendar.current.date(
            byAdding: .month, value: 1, to: date
          )!

          TrackerLogView(tracker: tracker, range: date...endDate) { results in
            if results.isEmpty, date >= Date().midnight {
              if Calendar.current.isDateInToday(date) {
                Color.blue.opacity(0.35)
                  .border(.white)
              } else if date > Date() {
                Color.clear
                  .border(.white)
              }
            } else {
              let monthly = monthly(results)
              let completion: CGFloat = min(CGFloat(monthly.completed) / CGFloat(monthly.total), 1)
              GeometryReader { p in
                Rectangle()
                  .stroke()
                  .background(
                    Group {
                      negateColors ? Color.red : Color.green
                    }
                    .frame(height: p.size.height * completion)
                    .frame(height: p.size.height, alignment: .bottom)
                  )
              }
            }
          }
        }
      }
    }
  }
}
