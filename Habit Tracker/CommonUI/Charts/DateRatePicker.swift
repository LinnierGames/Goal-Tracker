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
  @Published var selectedDateWindow = DateWindow.week
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
    case .week, .month, .year:
      return selectedDate.addingTimeInterval(.init(days: 7))
//    case .month:
//      return selectedDate.addingTimeInterval(.init(days: 31))
//    case .year:
//      return selectedDate.addingTimeInterval(.init(days: 365))
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
