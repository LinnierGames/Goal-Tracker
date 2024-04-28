//
//  GoalDashboardsScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 12/9/23.
//

import CoreData
import Charts
import SwiftUI

struct GoalDashboardsScreen: View {
  @Environment(\.managedObjectContext) var viewContext

  @State private var childNavigation = NavigationPath()
  @StateObject private var dateRange =
    DateRangePickerViewModel(intialDate: Date(), intialWindow: .week)

  var body: some View {
    NavigationView {
      VStack {
        DateRangePicker(viewModel: dateRange)
          .padding(.horizontal)

        NavigationStack(path: $childNavigation) {
          GeometryReader { p in
            ScrollView(.horizontal) {
              LazyHStack(spacing: 0) {
                feelingEnergizedTab()
                  .frame(width: p.size.width)
                eatingHealthyTab()
                  .frame(width: p.size.width)
                postureTab()
                  .frame(width: p.size.width)
              }
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
          }
        }
      }
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          SheetLink {
            GoalsScreen()
          } label: {
            Label("old", systemImage: "list.bullet.clipboard")
          }
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
          getOutOfBed()
          goToBed()
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

  @ViewBuilder
  func cooked() -> some View {
    ATrackerView("🧑‍🍳 Cooked") { tracker in
      DidCompleteChart(tracker: tracker)
    }
    TrackerView("🧑‍🍳 Cooked") { tracker in
      NavigationLink {
        HistogramChart(
          tracker,
          range: dateRange.startDate...dateRange.endDate
        ) { logs in
          logs.compactMap { log in
            log.allValues.first(where: {
              $0.field?.title == "Food"
            })?.string.sanitize(.capitalized, .whitespaceTrimmed)
          }
        }
        .navigationTitle("Exercise: Recipes")
      } label: {
        Text("View Recipes")
      }
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
          tracker,
          range: dateRange.startDate...dateRange.endDate
        ) { logs in
          logs.compactMap { log in
            log.allValues.first(where: {
              $0.field?.title == "Restaurant"
            })?.string.sanitize(.capitalized, .whitespaceTrimmed)
          }
        }
        .navigationTitle("Eat Fast Food: Restaurants")
      } label: {
        Text("View Restaurants")
      }
    }
  }

  @ViewBuilder
  func eatEachMeal() -> some View {
    ManyTrackersView(
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

    StateView(Optional<Tracker>.none) { selectedTracker in
      TrackersView(
        trackerNames: "🍔 Eat Breakfast", "🍖 Eat Lunch", "🍱 Eat Dinner"
      ) { breakfast, lunch, dinner in
        Menu {
          Button("Breakfast") {
            selectedTracker.wrappedValue = breakfast
          }
          Button("Lunch") {
            selectedTracker.wrappedValue = lunch
          }
          Button("Dinner") {
            selectedTracker.wrappedValue = dinner
          }
        } label: {
          HStack {
            Text("View Foods")
            Spacer()
            Image(systemName: "chevron.right")
              .foregroundStyle(.gray)
          }
          .foregroundStyle(.foreground)
          .contentShape(Rectangle())
        }
        .navigationDestination(item: selectedTracker) { tracker in
          HistogramChart(
            tracker, // TODO: multiple trackers for histogram
            range: dateRange.startDate...dateRange.endDate
          ) { logs in
            logs.compactMap { log in
              log.allValues.first(where: {
                $0.field?.title == "Food"
              })?.string.sanitize(.capitalized, .whitespaceTrimmed)
            }
            .map { $0.split(separator: ", ").map(String.init) }
            .flatMap { $0 }
          }
          .navigationTitle("\(tracker.title ?? "Meals"): Food")
        }
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

  @ViewBuilder
  func feelingTired() -> some View {
    ATrackerView("🥱 Feeling Tired") { tracker in
      DidCompleteChart(tracker: tracker, negateColors: true) { logs, _ in
        Text(logs.count, format: .number)
          .font(.system(size: 6))
      }
    }
    
    TrackerView("🥱 Feeling Tired") { tracker in
      NavigationLink {
        HistogramChart(
          tracker,
          range: dateRange.startDate...dateRange.endDate
        ) { logs in
          logs.compactMap { log in
            log.allValues.first(where: {
              $0.field?.title == "Activity"
            })?.string.sanitize(.capitalized, .whitespaceTrimmed)
          }
        }
        .navigationTitle("Feeling Tired: Activities")
      } label: {
        Text("View Activities")
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

  @ViewBuilder
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

    TrackerView("Exercise") { tracker in
      NavigationLink {
        HistogramChart(
          tracker,
          range: dateRange.startDate...dateRange.endDate
        ) { logs in
          logs.compactMap { log in
            log.allValues.first(where: {
              $0.field?.title == "Workout"
            })?.string.sanitize(.capitalized, .whitespaceTrimmed)
          }
        }
        .navigationTitle("Exercise: Workouts")
      } label: {
        Text("View Workouts")
      }
    }
  }

  func goToBed() -> some View {
    func matchesPredicate(log: TrackerLog) -> Bool {
      guard let timestamp = log.timestamp else { return false }

      let components = Calendar.current.dateComponents([.hour, .minute, .weekday], from: timestamp)
      guard
        let hour = components.hour,
        let minute = components.minute
      else {
        assertionFailure("missing date component")
        return false
      }

      // log.timestamp isBetween 10pm and 11:45pm
      if hour == 23, minute < 45 {
        return true
      } else if hour == 22 {
        return true
      }

      return false
    }

    return ATrackerView("Go To Bed", title: "💤 Go to bed") { tracker in
      DidCompleteChart(
        tracker: tracker,
        daily: { logs, _ in
          if logs.isEmpty {
            return .gray.opacity(0.35)
          } else if logs.contains(where: matchesPredicate(log:)) {
            return .green
          } else {
            return .red.opacity(0.35)
          }
        }, monthly: { logs in
          (logs.filter(matchesPredicate(log:)).count, 30)
        }, label: { logs, _ in
          if let log = logs.first(where: matchesPredicate(log:)), let timestamp = log.timestamp {
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
    func matchesPredicate(log: TrackerLog) -> Bool {
      guard let timestamp = log.timestamp else { return false }

      let components = Calendar.current.dateComponents([.hour, .minute, .weekday], from: timestamp)
      guard
        let hour = components.hour,
        let minute = components.minute,
        let weekday = components.weekday.flatMap(Weekday.init(rawValue:))
      else {
        assertionFailure("missing date component")
        return false
      }

      switch weekday {
      case .saturday, .sunday:

        // log.timestamp isBetween 7am and 9:10am
        if hour == 9, minute < 10 {
          return true
        } else if hour == 7 || hour == 8 {
          return true
        }
      default:

        // log.timestamp isBetween 6am and 8:10am
        if hour == 8, minute < 10 {
          return true
        } else if hour == 6 || hour == 7 {
          return true
        }
      }

      return false
    }

    return ATrackerView("Get Out Of Bed", title: "☀️ Get out of bed") { tracker in
      SheetLink {
        TrackerDetailScreen(tracker, dateRange: dateRange.selectedDate, dateRangeWindow: dateRange.selectedDateWindow)
      } label: {
        DidCompleteChart(
          tracker: tracker,
          daily: { logs, _ in
            if logs.isEmpty {
              return .gray.opacity(0.35)
            } else if logs.contains(where: matchesPredicate(log:)) {
              return .green
            } else {
              return .red.opacity(0.35)
            }
          }, monthly: { logs in
            (logs.filter(matchesPredicate(log:)).count, 30)
          }, label: { logs, _ in
            if let log = logs.first(where: matchesPredicate(log:)), let timestamp = log.timestamp {
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
  let title: String
  let label: (Tracker) -> Label

  init(_ tracker: String, title: String = "", @ViewBuilder label: @escaping (Tracker) -> Label) {
    self.tracker = tracker
    self.title = title.isEmpty ? tracker : title
    self.label = label
  }

  @EnvironmentObject var dateRange: DateRangePickerViewModel

  var body: some View {
    TrackerView(tracker) { tracker in
      NavigationSheetLink(buttonOnly: true) {
        TrackerDetailScreen(tracker, dateRange: dateRange.selectedDate, dateRangeWindow: dateRange.selectedDateWindow)
      } label: {
        VStack(alignment: .leading) {
          Text(title)
          label(tracker)
        }
      }
    }
  }
}

struct ManyTrackersView<Label: View>: View {
  @State private var detailTracker: Tracker?

  let content: (@escaping (Tracker) -> Void) -> AnyView

  init(
    trackerNames t1: String,
    _ t2: String,
    @ViewBuilder
    label: @escaping (Tracker, Tracker) -> Label
  ) {
    content = { presentTracker in
      TrackersView(trackerNames: t1, t2) { t1, t2 in
        Menu {
          Button {
            presentTracker(t1)
          } label: {
            Text(t1.title ?? "")
          }
          Button {
            presentTracker(t2)
          } label: {
            Text(t2.title ?? "")
          }
        } label: {
          label(t1, t2)
        }
      }.erasedToAnyView()
    }
  }

  init(
    trackerNames t1: String,
    _ t2: String,
    _ t3: String,
    @ViewBuilder
    label: @escaping (Tracker, Tracker, Tracker) -> Label
  ) {
    content = { presentTracker in
      TrackersView(trackerNames: t1, t2, t3) { t1, t2, t3 in
        Menu {
          Button {
            presentTracker(t1)
          } label: {
            Text(t1.title ?? "")
          }
          Button {
            presentTracker(t2)
          } label: {
            Text(t2.title ?? "")
          }
          Button {
            presentTracker(t3)
          } label: {
            Text(t3.title ?? "")
          }
        } label: {
          label(t1, t2, t3)
        }
      }.erasedToAnyView()
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
    content = { presentTracker in
      TrackersView(trackerNames: t1, t2, t3, t4) { t1, t2, t3, t4 in
        Menu {
          Button {
            presentTracker(t1)
          } label: {
            Text(t1.title ?? "")
          }
          Button {
            presentTracker(t2)
          } label: {
            Text(t2.title ?? "")
          }
          Button {
            presentTracker(t3)
          } label: {
            Text(t3.title ?? "")
          }
          Button {
            presentTracker(t4)
          } label: {
            Text(t4.title ?? "")
          }
        } label: {
          label(t1, t2, t3, t4)
        }
      }.erasedToAnyView()
    }
  }

  var body: some View {
    content {
      detailTracker = $0
    }
    .sheet(item: $detailTracker) { tracker in
      TrackerDetailScreen(tracker)
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
        content(trackers)
          .addLogContextMenu(viewContext: viewContext, trackers: trackers)
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
    }
  }
}

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
          .addLogContextMenu(viewContext: viewContext, tracker: tracker)
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

extension View {
  func erasedToAnyView() -> AnyView {
    AnyView(self)
  }
}
