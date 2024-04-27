//
//  GoalDashboardsScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 12/9/23.
//

import Charts
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

        NavigationView {
          TabView {
            feelingEnergizedTab()
            eatingHealthyTab()
            postureTab()
          }.tabViewStyle(.page)
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

  func eatingHealthyTab() -> some View {
    VStack {
      Text("Eating Healthy")
        .font(.title2)

      Form {
        Section {
          eatEachMeal()
          fastFood()
        } header: {
          Text("Meals")
        }

        Section {
          cooked()
          ateASnack()
        } header: {
          Text("Diets")
        }

        Section {
          exercise()
        } header: {
          Text("Activeness")
        }

        Section {
          oohBoi()
          feelingTired()
        } header: {
          Text("Results")
        }
      }
    }
  }

  func feelingEnergizedTab() -> some View {
    VStack {
      Text("Feeling Energized")
        .font(.title2)

      Form {
        Section {
          goToBed()
          getOutOfBed()
        } header: {
          Text("Bed times")
        }
        Section {
          noseRinse()
          usedCPAP()
          naps()
        } header: {
          Text("Sleep Hygiene")
        }

        Section {
          fullBodyStretch()
          exercise()
        } header: {
          Text("Activeness")
        }

        Section {
          feelingTired()
        } header: {
          Text("Results")
        }
      }
    }
  }

  func postureTab() -> some View {
    VStack {
      Text("Improve Posture")
        .font(.title2)

      Form {
        Section {
          upperBodyStretch()
          fullBodyStretch()
          physicalTherapy()
          exercise()
        } header: {
          Text("Improvements")
        }

        Section {
          feelingBackPain()
        } header: {
          Text("Results")
        }
      }
    }
  }

  func feelingBackPain() -> some View {
    ATrackerView("😣 Upper Back Pain") { tracker in
      DidCompleteChart(tracker: tracker, negateColors: true)
    }
  }

  func physicalTherapy() -> some View {
    ATrackerView("Physical Therapy") { tracker in
      DidCompleteChart(tracker: tracker)
    }
  }

  func oohBoi() -> some View {
    ATrackerView("💩 Ooh Boi") { tracker in
      DidCompleteChart(tracker: tracker, negateColors: true)
    }
  }

  func ateASnack() -> some View {
    ATrackerView("🌭 Ate a Snack") { tracker in
      DidCompleteChart(tracker: tracker)
    }
  }

  func cooked() -> some View {
    ATrackerView("🧑‍🍳 Cooked") { tracker in
      DidCompleteChart(tracker: tracker)
    }
  }

  @ViewBuilder
  func fastFood() -> some View {
    ATrackerView("🌯 Eat Fast Food") { tracker in
      TrackerBarChart(
        tracker,
        range: dateRange.startDate...dateRange.endDate,
        granularity: dateRange.selectedDateWindow,
        width: .short,
        context: viewContext
      )
      .frame(height: 64)
    }

    TrackerView("🌯 Eat Fast Food") { tracker in
      NavigationLink {
        HistogramChart(
          tracker: tracker,
          range: dateRange.startDate...dateRange.endDate
        ) { logs in
          logs.compactMap { log in
            log.allValues.first(where: {
              $0.field?.title == "Restaurant"
            })?.string
          }
        }
      } label: {
        Text("View Restaurants")
      }
    }
  }

  @ViewBuilder
  func eatEachMeal() -> some View {
    TrackersView(
      trackerNames: "🍔 Eat Breakfast", "🍖 Eat Lunch", "🍱 Eat Dinner"
    ) { breakfast, lunch, dinner in
      TrackerPlotChart(
        breakfast, lunch, dinner,
        range: dateRange.startDate...dateRange.endDate,
        logDate: .both,
        granularity: dateRange.selectedDateWindow,
        width: .short,
        annotations: [],
        context: viewContext
      )
      .frame(height: 132)
    }

    TrackersView(
      trackerNames: "🍔 Eat Breakfast", "🍖 Eat Lunch", "🍱 Eat Dinner"
    ) { breakfast, lunch, dinner in
      NavigationLink {
        Text("TODO: multiple trackers for histogram")
      } label: {
        Text("View Meals")
      }
    }
  }

  func upperBodyStretch() -> some View {
    ATrackerView("Upper body stretch") { tracker in
      DidCompleteChart(tracker: tracker)
    }
  }

  func fullBodyStretch() -> some View {
    ATrackerView("Full body stretch") { tracker in
      DidCompleteChart(tracker: tracker)
    }
  }

  func naps() -> some View {
    ATrackerView("💤 Nap") { tracker in
      DidCompleteChart(tracker: tracker, negateColors: true) { logs, _ in
        Text(logs.count, format: .number)
          .font(.system(size: 6))
      }
    }
  }

  func feelingTired() -> some View {
    ATrackerView("🥱 Feeling Tired") { tracker in
      DidCompleteChart(tracker: tracker, negateColors: true) { logs, _ in
        Text(logs.count, format: .number)
          .font(.system(size: 6))
      }
    }
  }

  func usedCPAP() -> some View {
    ATrackerView("Used CPAP") { tracker in
      DidCompleteChart(tracker: tracker)
    }
  }

  func noseRinse() -> some View {
    ATrackerView("Nose Rinse") { tracker in
      DidCompleteChart(tracker: tracker)
    }
  }

  func exercise() -> some View {
    ATrackerView("Exercise") { tracker in
      DidCompleteChart(tracker: tracker) { logs, _ in
        let duration: TimeInterval = logs.reduce(into: 0) { sum, log in
          guard let startTime = log.timestamp, let endTime = log.endDate else {
            return
          }

          sum += endTime.timeIntervalSince(startTime)
        }

        if duration > 0 {
          Text(duration, format: .duration)
            .font(.system(size: 6))
        } else {
          EmptyView()
        }
      }
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
        daily: { logs, _ in
          if logs.isEmpty {
            return .gray.opacity(0.35)
          } else if let _ = matchesPredicate(logs: logs) {
            return .green
          } else {
            return .red.opacity(0.35)
          }
        }, label: { logs, _ in
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
          daily: { logs, _ in
            if logs.isEmpty {
              return .gray.opacity(0.35)
            } else if let _ = matchesPredicate(logs: logs) {
              return .green
            } else {
              return .red.opacity(0.35)
            }
          }, label: { logs, _ in
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


/// Base view for single hardcoded tracker rows
struct ATrackerView<Label: View>: View {
  let tracker: String
  let label: (Tracker) -> Label

  init(_ tracker: String, @ViewBuilder label: @escaping (Tracker) -> Label) {
    self.tracker = tracker
    self.label = label
  }

  @EnvironmentObject var dateRange: DateRangePickerViewModel

  var body: some View {
    TrackerView(tracker) { tracker in
      NavigationSheetLink(buttonOnly: true) {
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

  let daily: ([TrackerLog], Date) -> Color
  let label: ([TrackerLog], Date) -> Label
  let negateColors: Bool

  init(
    tracker: Tracker,
    daily: @escaping ([TrackerLog], Date) -> Color,
    @ViewBuilder
    label: @escaping ([TrackerLog], Date) -> Label
  ) {
    self.tracker = tracker
    self.daily = daily
    self.label = label
    self.negateColors = false
  }

  init(
    tracker: Tracker,
    negateColors: Bool = false
  ) where Label == EmptyView {
    self.tracker = tracker
    self.daily = { logs, date in
      if logs.isEmpty {
        negateColors ? .green : .red.opacity(0.35)
      } else {
        negateColors ? .red.opacity(0.35) : .green
      }
    }
    self.label = { _,_ in EmptyView() }
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
        negateColors ? .green : .red.opacity(0.35)
      } else {
        negateColors ? .red.opacity(0.35) : .green
      }
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
              daily(Array(results), date)
                .border(.white)
                .overlay(label(Array(results), date))
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
              let completion = min(CGFloat(results.count) / 30, 1)
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

#Preview {

  GeometryReader { p in
    Rectangle()
      .stroke()
      .background(
        Color.green
          .frame(height: p.size.height * 0.37)
          .frame(height: p.size.height, alignment: .bottom)
      )
  }
  .frame(width: 32, height: 32)
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

struct TrackersView<Label: View>: View {
  let trackerNames: [String]
  let content: ([Tracker]) -> Label

  @State private var missingTrackers: [String] = []
  @State private var trackers: [Tracker] = []
  @State private var detailTracker: Tracker?

  @Environment(\.managedObjectContext) var viewContext

  init(
    trackerNames t1: String,
    _ t2: String,
    @ViewBuilder
    label: @escaping (Tracker, Tracker) -> Label
  ) {
    trackerNames = [t1, t2]
    content = { trackers in
      label(trackers[0], trackers[1])
    }
  }
  
  init(
    trackerNames t1: String,
    _ t2: String,
    _ t3: String,
    @ViewBuilder
    label: @escaping (Tracker, Tracker, Tracker) -> Label
  ) {
    trackerNames = [t1, t2, t3]
    content = { trackers in
      label(trackers[0], trackers[1], trackers[2])
    }
  }

  init(
    trackerNames t1: String,
    _ t2: String,
    _ t3: String,
    _ t4: String,
    @ViewBuilder
    label: @escaping (Tracker, Tracker, Tracker, Tracker) -> Label
  ) {
    trackerNames = [t1, t2, t3, t4]
    content = { trackers in
      label(trackers[0], trackers[1], trackers[2], trackers[3])
    }
  }

  var body: some View {
    Group {
      if trackers.isEmpty {
        Text("Trackers not found: \(missingTrackers.joined(separator: ", "))")
      } else {

        // TODO: Abstract this out to another layer (e.g. ATrackerView)
        Menu {
          ForEach(trackers) { tracker in
            Button {
              detailTracker = tracker
            } label: {
              Text(tracker.title ?? "")
            }
          }
        } label: {
          content(trackers)
        }
      }
    }.onAppear {
      do {
        var foundTrackers: [Tracker] = []
        for trackerName in trackerNames {
          let trackerByName = Tracker.fetchRequest()
          trackerByName.predicate = NSPredicate(format: "title == %@", trackerName)

          let result = try viewContext.fetch(trackerByName)

          if let tracker = result.first {
            foundTrackers.append(tracker)
          } else {
            missingTrackers.append(trackerName)
          }
        }

        guard foundTrackers.count == trackerNames.count else {
          return
        }

        trackers = foundTrackers
      } catch {
        trackers = []
        missingTrackers = []
        assertionFailure("Failed to fetch: \(error)")
      }
    }.sheet(item: $detailTracker) { tracker in
      TrackerDetailScreen(tracker)
    }
  }
}
