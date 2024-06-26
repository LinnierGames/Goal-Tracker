//
//  DateRatePicker.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 2/9/23.
//

import Combine
import SwiftUI

enum DateWindow: String, CaseIterable, Identifiable {
  var id: Self { self }
  case day, week, month, year
}

typealias DateRangePickerUpdate = (
  window: DateWindow, range: ClosedRange<Date>
)

class DateRangePickerViewModel: ObservableObject {
  @Published var selectedDateWindow: DateWindow {
    didSet {
      updateStartDateToNewWindow()
    }
  }
  @Published var selectedDate: Date {
    didSet {
      endDateOverride = nil
      rangeTitleOverride = nil
      didUpdateRangePublisher.send((selectedDateWindow, startDate...endDate))
    }
  }

  private let didUpdateRangePublisher = PassthroughSubject<DateRangePickerUpdate, Never>()
  var didUpdateRange: AnyPublisher<DateRangePickerUpdate, Never> {
    didUpdateRangePublisher.eraseToAnyPublisher()
  }

  private let calendar = Calendar.current

  init(intialDate: Date, intialWindow: DateWindow) {
    self.selectedDate = intialDate
    self.selectedDateWindow = intialWindow

    updateStartDateToNewWindow()
  }

  var selectedDateLabel: String {
    if let rangeTitleOverride {
      return rangeTitleOverride
    } else if let endDateOverride {
      let formatter = DateIntervalFormatter()
      formatter.dateStyle = .short
      formatter.timeStyle = .none
      return formatter.string(from: selectedDate, to: endDateOverride)
    } else {
      return DateFormatter.localizedString(from: selectedDate, dateStyle: .long, timeStyle: .none)
    }
  }

  var startDate: Date { selectedDate }
  private var endDateOverride: Date?

  /// Override to show for the picker's title
  private var rangeTitleOverride: String?
  var endDate: Date {
    if let endDateOverride {
      return endDateOverride
    }

    switch selectedDateWindow {
    case .day:
      return calendar.date(byAdding: .day, value: 1, to: selectedDate)!
    case .week:
      return calendar.date(byAdding: .weekOfMonth, value: 1, to: selectedDate)!
    case .month:
      return calendar.date(byAdding: .month, value: 1, to: selectedDate)!
    case .year:
      return calendar.date(byAdding: .year, value: 1, to: selectedDate)!
    }
  }

  func moveDateToToday() {
    selectedDate = Date()
    updateStartDateToNewWindow()
  }

  func moveDateForward() {
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

  func moveToCustomDate(start: Date, end: Date, title: String? = nil) {
    selectedDate = start
    endDateOverride = end
    rangeTitleOverride = title
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

struct DateRangePicker: View {
  @ObservedObject private var viewModel: DateRangePickerViewModel

  @State private var isShowingDatePicker = false

  init(viewModel: DateRangePickerViewModel) {
    self._viewModel = ObservedObject(wrappedValue: viewModel)
  }

  var body: some View {
    VStack {

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
        Button(viewModel.selectedDateLabel, action: viewModel.moveDateToToday)
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
      HStack {
        Picker("", selection: $viewModel.selectedDateWindow) {
          ForEach(DateWindow.allCases) { window in
            Text(window.rawValue.capitalized)
          }
        }
        .pickerStyle(.segmented)

        Button(
          action: {
            isShowingDatePicker = true
          }, systemImage: "calendar"
        )
        .iosPopover(isPresented: $isShowingDatePicker) {
          DatePickerPopover(
            startDate: viewModel.startDate,
            endDate: viewModel.endDate
          ) { startDate, endDate, titleOverride in
            viewModel.moveToCustomDate(start: startDate, end: endDate, title: titleOverride)
          }
        }
      }
    }
  }

  struct DatePickerPopover: View {
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var didCommit = false

    @Environment(\.dismiss) var dismiss

    let completion: (Date, Date, String?) -> Void

    init(
      startDate: Date,
      endDate: Date,
      completion: @escaping (Date, Date, String?) -> Void
    ) {
      self.startDate = startDate
      self.endDate = endDate
      self.completion = completion
    }

    var body: some View {
      VStack(spacing: 18) {
        VStack {
          Text("Date Ranges")
          DatePicker(
            "Start",
            selection: $startDate,
            in: ...endDate,
            displayedComponents: .date
          )
          DatePicker(
            "End",
            selection: $endDate,
            in: startDate...,
            displayedComponents: .date
          )
        }

        VStack {
          Text("Days Ago")
          HStack {
            ForEach([7, 14, 30, 60, 90], id: \.self) { daysAgo in
              Button {
                let firstDay = Date(timeIntervalSinceNow: .init(days: -daysAgo))
                let nextDay = Date().midnight.addingTimeInterval(.init(days: 1))
                startDate = firstDay
                endDate = nextDay
                commit(titleOverride: "\(daysAgo) days ago")
              } label: {
                Text(daysAgo, format: .number)
              }
              .buttonStyle(BorderedProminentButtonStyle())
            }
          }
        }
      }
      .padding()
      .onDisappear {
        commit()
      }
    }

    func commit(titleOverride: String? = nil) {
      guard !didCommit else { return }
      didCommit = true
      completion(startDate, endDate, titleOverride)
//      dismiss()
    }
  }
}

#Preview {
  VStack {
    DateRangePicker(viewModel: DateRangePickerViewModel(intialDate: Date(), intialWindow: .week))
      .padding()

    Spacer()
  }
}
