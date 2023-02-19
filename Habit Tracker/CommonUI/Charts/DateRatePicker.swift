//
//  DateRatePicker.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 2/9/23.
//

import SwiftUI

enum DateWindow: String, CaseIterable, Identifiable {
  var id: Self { self }
  case day, week, month, year
}

class DateRangePickerViewModel: ObservableObject {
  @Published var selectedDateWindow = DateWindow.week {
    didSet {
      updateStartDateToNewWindow()
    }
  }
  @Published var selectedDate: Date

  init(intialDate: Date) {
    let calendar = Calendar.current
    let sunday = calendar.date(
      from: calendar.dateComponents(
        [.yearForWeekOfYear, .weekOfYear],
        from: intialDate
      )
    )

    self.selectedDate = calendar.date(byAdding: .day, value: 0, to: sunday!)!
  }

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
    case .month, .year:
      return selectedDate.addingTimeInterval(.init(days: 31))
//    case .year:
//      return selectedDate.addingTimeInterval(.init(days: 365))
    }
  }

  func moveDateForward() {
    let calendar = Calendar.current
    switch selectedDateWindow {
    case .day:
      selectedDate = calendar.date(byAdding: .day, value: 1, to: selectedDate)!
    case .week:
      selectedDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate)!
    case .month:
      selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate)!
    case .year:
      selectedDate = calendar.date(byAdding: .year, value: 1, to: selectedDate)!
    }
  }

  func moveDateBackward() {
    let calendar = Calendar.current
    switch selectedDateWindow {
    case .day:
      selectedDate = calendar.date(byAdding: .day, value: -1, to: selectedDate)!
    case .week:
      selectedDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate)!
    case .month:
      selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate)!
    case .year:
      selectedDate = calendar.date(byAdding: .year, value: -1, to: selectedDate)!
    }
  }

  private func updateStartDateToNewWindow() {
    let calendar = Calendar.current
    switch selectedDateWindow {
    case .day:
      let selectedDateIsWithinThisWeek =
        calendar.isDate(selectedDate, equalTo: Date(), toGranularity: .weekOfYear)
      if selectedDateIsWithinThisWeek {
        selectedDate = Date().set(minute: 0, hour: 0)
      } else {
        selectedDate = selectedDate.set(minute: 0, hour: 0)
      }
    case .week:
      let sunday = calendar.date(
        from: calendar.dateComponents(
          [.yearForWeekOfYear, .weekOfYear],
          from: selectedDate
        )
      )

      self.selectedDate = calendar.date(byAdding: .day, value: 0, to: sunday!)!
    case .month:
      self.selectedDate = selectedDate.set(day: 1)
    case .year:
      self.selectedDate = selectedDate.set(day: 1, month: 1)
    }
  }
}


private class DateRangePickerViewModel2: ObservableObject {
  @Binding var selectedDateWindow: DateWindow
  @Binding var selectedDate: Date

  init(selectedDate: Binding<Date>, selectedDateWindow: Binding<DateWindow>) {
    self._selectedDateWindow = selectedDateWindow
    self._selectedDate = selectedDate
  }

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

struct DateRangePicker: View {
  @ObservedObject private var viewModel: DateRangePickerViewModel

  init(viewModel: DateRangePickerViewModel) {
    self._viewModel = ObservedObject(wrappedValue: viewModel)
  }

  var body: some View {

    // Range Picker
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

    // Window Picker
    Picker("", selection: $viewModel.selectedDateWindow) {
      ForEach(DateWindow.allCases) { window in
        Text(window.rawValue.capitalized)
      }
    }
    .pickerStyle(.segmented)
  }
}
