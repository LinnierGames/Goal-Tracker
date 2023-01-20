//
//  HabitDetailsChartsScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/15/23.
//

import Charts
import MetricKit
import SwiftUI

struct HabitDetailsChartScreen: View {
  @ObservedObject var habit: Habit

  @StateObject private var viewModel = HabitDetailsChartViewModel()

  @FetchRequest
  private var entries: FetchedResults<HabitEntry>

  @Environment(\.managedObjectContext) private var viewContext

  init(_ habit: Habit) {
    self.habit = habit
    self._entries = FetchRequest(
      sortDescriptors: [SortDescriptor(\HabitEntry.timestamp)],
      predicate: NSPredicate(format: "habit = %@", habit)
    )
  }

  var body: some View {
    NavigationView {
      VStack {
        // Range Picker
        makeRangePicker()

        // Window Picker
        Picker("Flavor", selection: $viewModel.selectedDateWindow) {
          ForEach(DateWindow.allCases) { window in
            Text(window.rawValue.capitalized)
          }
        }
        .pickerStyle(.segmented)

        // Charts
        VStack {
          switch viewModel.selectedDateWindow {
          case .day:
            makeDayView()
          case .week:
            makeWeekView()
          case .month:
            makeMonthView()
          case .year:
            makeYearView()

            // TODO: support smaller bucket sizes within each window (e.g. see weeks in a month vs days)
          }
        }
        .frame(height: 196)

        Spacer()
      }
      .padding(.horizontal)

      .navigationTitle(habit.title!)
    }
  }

  private func makeRangePicker() -> some View {
    HStack {
      Button(action: viewModel.moveDateBackward) {
        Image(systemName: "chevron.left")
          .foregroundColor(.black)
          .padding()
          .background(Color.yellow.grayscale(1))
          .cornerRadius(8)
      }
      Spacer()
      Text(viewModel.selectedDateLabel)
      Spacer()
      Button(action: viewModel.moveDateForward) {
        Image(systemName: "chevron.right")
          .foregroundColor(.black)
          .padding()
          .background(Color.yellow.grayscale(1))
          .cornerRadius(8)
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
    let data = stride(from: viewModel.startDate.midnight, to: viewModel.endDate.midnight, by: hour)
      .map { day in
        let nEntriesForDay: Int = {
          let lowerBound = day.set(minute: 0)
          let upperBound = day.set(minute: 0).addingTimeInterval(.init(hours: 1))
          let fetch = HabitEntry.fetchRequest()
          fetch.predicate = NSPredicate(
            format: "habit = %@ AND timestamp >= %@ AND timestamp < %@",
            habit, lowerBound as NSDate, upperBound as NSDate
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
    let day: TimeInterval = 60*60*24
    let data = stride(from: viewModel.startDate, to: viewModel.endDate, by: day)
      .map { day in
        let nEntriesForDay: Int = {
          let fetch = HabitEntry.fetchRequest()
          fetch.predicate = NSPredicate(
            format: "habit = %@ AND timestamp >= %@ AND timestamp < %@",
            habit, day.midnight as NSDate,
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

  private func makeMonthView() -> some View {
    let day: TimeInterval = 60*60*24
    let data = stride(from: viewModel.startDate, to: viewModel.endDate, by: day)
      .map { day in
        let nEntriesForDay: Int = {
          let fetch = HabitEntry.fetchRequest()
          fetch.predicate = NSPredicate(
            format: "habit = %@ AND timestamp >= %@ AND timestamp < %@",
            habit, day.midnight as NSDate,
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

private enum DateWindow: String, CaseIterable, Identifiable {
  var id: Self { self }
  case day, week, month, year
}

private class HabitDetailsChartViewModel: ObservableObject {
  @Published var selectedDateWindow = DateWindow.week
  @Published var selectedDate: Date = {
    let calendar = Calendar.current
    let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))
    return calendar.date(byAdding: .day, value: 0, to: sunday!)!
  }() // Date(timeIntervalSince1970: 1557973862) June 2019

  var selectedDateLabel: String {
    DateFormatter.localizedString(from: selectedDate, dateStyle: .long, timeStyle: .none)
  }

  var startDate: Date { selectedDate }
  var endDate: Date {
    switch selectedDateWindow {
    case .day:
      return selectedDate.addingTimeInterval(.init(days: 1))
    case .week:
      return selectedDate.addingTimeInterval(.init(days: 7))
    case .month:
      return selectedDate.addingTimeInterval(.init(days: 31))
    case .year:
      return selectedDate.addingTimeInterval(.init(days: 365))
    }
  }

  func moveDateForward() {
    switch selectedDateWindow {
    case .day:
      selectedDate = selectedDate.addingTimeInterval(.init(days: 1))
    case .week:
      selectedDate = selectedDate.addingTimeInterval(.init(days: 7))
    case .month:
      selectedDate = selectedDate.addingTimeInterval(.init(days: 31))
    case .year:
      selectedDate = selectedDate.addingTimeInterval(.init(days: 365))
    }
  }

  func moveDateBackward() {
    switch selectedDateWindow {
    case .day:
      selectedDate = selectedDate.addingTimeInterval(.init(days: -1))
    case .week:
      selectedDate = selectedDate.addingTimeInterval(.init(days: -7))
    case .month:
      selectedDate = selectedDate.addingTimeInterval(.init(days: -31))
    case .year:
      selectedDate = selectedDate.addingTimeInterval(.init(days: -365))
    }
  }
}
