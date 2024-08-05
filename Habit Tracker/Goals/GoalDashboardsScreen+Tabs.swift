//
//  GoalDashboardsScreen+Tabs.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 4/28/24.
//

import Charts
import SwiftUI

let BasicPlotSymbol = BasicChartSymbolShape.circle

#Preview {
  Form {
    TabHeader(title: "Health!", systemName: "heart.fill", color: .red) {
      Text("dsalfks asf jsdafl sj fklsf ")
      Text("dsalfks asf jsdafl ")

      LazyHGrid(rows: [.init(), .init()], content: {
        GoalCapsule(goal: "sdfa", style: .increase)
        GoalCapsule(goal: "ff", style: .increase)
        GoalCapsule(goal: "sddffa", style: .increase)
        GoalCapsule(goal: "sdffffffdfa", style: .decrease)
        GoalCapsule(goal: "sdsfdfa", style: .increase)
        GoalCapsule(goal: "sdfdfa", style: .increase)
        GoalCapsule(goal: "sdfa", style: .increase)
        GoalCapsule(goal: "sdfa", style: .increase)
      })
    }

    Section {
      Text("Sup")
    }
  }
}

struct GoalCapsule: View {
  enum Style {
    case increase, decrease

    var color: Color {
      switch self {
      case .increase: .green
      case .decrease: .red
      }
    }

    var badge: Image {
      switch self {
      case .increase: Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
      case .decrease: Image(systemName: "chart.line.downtrend.xyaxis.circle.fill")
      }
    }
  }

  let goal: String
  let style: Style

  var body: some View {
    HStack(spacing: 2) {
      style.badge
        .foregroundStyle(style.color)
      Text(goal)
        .lineLimit(1)
    }
    .padding(.trailing, 4)
    .padding(4)
    .background {
      Capsule()
        .foregroundStyle(style.color.opacity(0.2))
    }
  }
}

struct TabHeader<Header: View>: View {
  let title: String
  let systemName: String
  let color: Color
  @ViewBuilder let header: () -> Header

  var body: some View {
    VStack {
      Image(systemName: systemName)
        .resizable()
        .aspectRatio(contentMode: .fit)
//        .opacity(0.8)
        .foregroundStyle(color)
        .frame(width: 48, height: 48)

        .padding(20)
        .background(
          Circle()
            .foregroundStyle(color.opacity(0.2))
        )
      Text(title)
        .font(.title)
      header()
        .font(.caption)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
    .listRowInsets(EdgeInsets())
    .listRowBackground(Color.clear)
  }
}

extension GoalDashboardsScreen {
  // MARK: - Tabs

  func chickieTab() -> some View {
    Form {
      TabHeader(title: "Chickie!", systemName: "heart.fill", color: .purple) {
        Text("Wuv ❤️")
      }

      Section {
        ATrackerView("⛹️‍♂️ Doing Something Unique") { tracker in
          DidCompleteChart(tracker: tracker)
        }
        ATrackerView("🍫 Date Night") { tracker in
          DidCompleteChart(tracker: tracker)
        }
        ATrackerView("🎥 GT Movies") { tracker in
          DidCompleteChart(tracker: tracker)
        }
        ATrackerView("💐 Do something romantic") { tracker in
          DidCompleteChart(tracker: tracker)
        }
        ATrackerView("🔦 GT Concert") { tracker in
          DidCompleteChart(tracker: tracker)
        }
      }

      Section {
        ATrackerView("🗣️ Discussion") { tracker in
          DidCompleteChart(tracker: tracker)
        }

        TrackerView("🗣️ Discussion") { tracker in
          NavigationLink {
            HistogramChart(
              tracker,
              range: dateRange.startDate...dateRange.endDate
            ) { logs in
              logs.compactMap { log in
                log.allValues.first(where: {
                  $0.field?.title == "Topic"
                })?.string.sanitize(.capitalized, .whitespaceTrimmed)
              }
            }
            .navigationTitle("🗣️ Discussion: Topcis")
          } label: {
            Text("View Topics")
          }

          DisclosureGroup {
            HistogramTable(tracker: tracker, fieldKey: "Topic")
          } label: {
            Text("View Topics Table")
          }
        }
      }
    }
    .safeAreaPadding(.bottom, 72)
  }

  func feelingEnergizedTab() -> some View {
    Form {
      TabHeader(title: "Feeling Energized", systemName: "bolt.square", color: .yellow) {
        VStack(spacing: 12) {
          Text("Get consistent on **bedtime**, **duration**, **quality**, and **wakeup time**")
          Text("Stay **active** during the day, use **CPAP**, **nose Rx**")
          HStack {
            GoalCapsule(goal: "Energy", style: .increase)
            GoalCapsule(goal: "Day-time sleepiness", style: .decrease)
          }
        }
      }

      Section {
        getOutOfBed(includeExtraCharts: true)
        goToBed(includeExtraCharts: true)
      } header: {
        Text("Bed times")
      }

      Section {
        noseRinse()
        stuffyNose()
        nightlySnacks()
        usedCPAP()
      } header: {
        Text("Sleep Hygiene")
      }

      Section {
        upperBodyStretch()
        fullBodyStretch()
        exercise()
      } header: {
        Text("Activeness")
      }

      Section {
        naps()
        feelingTired()
        feelingTiredDuringMeals()
      } header: {
        Text("Results")
      }
    }
    .safeAreaPadding(.bottom, 72)
  }

  func eatingHealthyTab() -> some View {
    Form {
      TabHeader(title: "Eating Healthy", systemName: "stethoscope.circle", color: .red) {
        VStack(spacing: 12) {
          Text("Cook and eat healthier")
          HStack {
            GoalCapsule(goal: "Bathroom problems", style: .decrease)
            GoalCapsule(goal: "Sleepiness", style: .decrease)
          }
        }
      }

      Section {
        diet()
        eatEachMeal()
      } header: {
        Text("Cooking and fast food")
      }
      Section {
        fastFood()
        cooked()
      }

      Section {
        exercise()
      } header: {
        Text("Activeness")
      }

      Section {
        oohBoi()
        feelingGassy()
        feelingTired()
      } header: {
        Text("Results")
      }
    }
    .safeAreaPadding(.bottom, 72)
  }

  func postureTab() -> some View {
    Form {
      TabHeader(title: "Improve Posture", systemName: "figure.stand", color: .brown) {
        VStack(spacing: 12) {
          Text("Strengthen my **posture**")
          HStack {
            GoalCapsule(goal: "Posture", style: .increase)
            GoalCapsule(goal: "Back pains", style: .decrease)
          }
        }
      }

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
    .safeAreaPadding(.bottom, 72)
  }

  // MARK: - Charts

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

  func feelingGassy() -> some View {
    ATrackerView("⛽️ Feeling Gassy") { tracker in
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
              $0.field?.title == "Dish"
            })?.string.sanitize(.capitalized, .whitespaceTrimmed)
          }
        }
        .navigationTitle("Exercise: Recipes")
      } label: {
        Text("View Recipes")
      }

      DisclosureGroup {
        HistogramTable(tracker: tracker, fieldKey: "Dish")
      } label: {
        Text("View Recipes Table")
      }
    }
  }

  @ViewBuilder
  func fastFood() -> some View {
    ATrackerView("🌯 Eat Fast Food") { tracker in
      DidCompleteChart(tracker: tracker, negateColors: true)
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

      DisclosureGroup {
        HistogramTable(tracker: tracker, fieldKey: "Restaurant", negateColors: true)
      } label: {
        Text("View Restaurant Table")
      }
    }
  }

  func diet() -> some View {
    func makeChart(meal: Tracker) -> some View {
      DidCompleteChart(
        tracker: meal
      ) { _, _ in
        Color.clear
      } monthly: { logs in
        (1, 1)
      } label: { mealLogs, date in
        TrackersView(
          trackerNames: "🌯 Eat Fast Food", "🧑‍🍳 Cooked"
        ) { fastFood, cooked in
          if
            let min = mealLogs.min(
              by: { $0.timestamp < $1.timestamp }
            )?.timestamp?.addingTimeInterval(-.init(minutes: 5)),
            let max = mealLogs.max(
              by: { $0.timestamp < $1.timestamp }
            )?.timestamp?.addingTimeInterval(.init(minutes: 5))
          {
            let dateRangeForMeal = min...max
            TrackerLogView(
              tracker: fastFood,
              range2: dateRangeForMeal
            ) { fastFood in
              if fastFood.isEmpty {
                TrackerLogView(
                  tracker: cooked,
                  range2: dateRangeForMeal
                ) { cooked in
                  if cooked.isEmpty {
                    Color.green
                  } else {
                    Color.orange
                      .overlay { Text("🧑‍🍳") }
                  }
                }
              } else {
                Color.red
                  .overlay { Text("🌯") }
              }
            }
          }
        }
      }
    }

    return Group {
      ATrackerView("🍔 Eat Breakfast") { breakfast in
        makeChart(meal: breakfast)
      }

      ATrackerView("🍖 Eat Lunch") { lunch in
        makeChart(meal: lunch)
      }

      ATrackerView("🍱 Eat Dinner") { lunch in
        makeChart(meal: lunch)
      }

      HStack {
        HStack(spacing: 4) {
          Rectangle().frame(width: 8, height: 8).foregroundStyle(.green)
          Text("Meal")
        }
        HStack(spacing: 4) {
          Rectangle().frame(width: 8, height: 8).foregroundStyle(.yellow)
          Text("🧑‍🍳 Cooked")
        }
        HStack(spacing: 4) {
          Rectangle().frame(width: 8, height: 8).foregroundStyle(.red)
          Text("🌯 Eat Fast Food")
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .font(.caption)
    }
  }

  @ViewBuilder
  func eatEachMeal() -> some View {
    ManyTrackersView(
      trackerNames: "🍔 Eat Breakfast", "🍖 Eat Lunch", "🍱 Eat Dinner", "🌯 Eat Fast Food"
    ) { breakfast, lunch, dinner, fastFood in
      TrackerPlotChart(
        (breakfast, .circle), (lunch, .circle), (dinner, .circle), (fastFood, .asterisk),
        range: dateRange.startDate...dateRange.endDate,
        logDate: .both,
        granularity: dateRange.selectedDateWindow,
        width: .short,
        annotations: [],
        context: viewContext
      )
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
      DidCompleteChart(tracker: tracker, negateColors: true)
    }
  }

  @ViewBuilder
  func feelingTired() -> some View {
    ATrackerView("🥱 Feeling Tired") { tracker in
      DidCompleteChart(tracker: tracker, negateColors: true)
    }

    ManyTrackersView(trackerNames: "🥱 Feeling Tired", "🥱 Feeling Tired") { tracker, _ in
      TrackerPlotChart(
        (tracker, .circle),
        range: dateRange.startDate...dateRange.endDate,
        logDate: .start,
        granularity: dateRange.selectedDateWindow,
        width: .short,
        annotations: [],
        context: viewContext
      )
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

      DisclosureGroup {
        HistogramTable(tracker: tracker, fieldKey: "Activity", negateColors: true)
      } label: {
        Text("View Activities Table")
      }
    }
  }

  @ViewBuilder
  func feelingTiredDuringMeals() -> some View {
    ManyTrackersView(
      trackerNames: "🥱 Feeling Tired", "🍔 Eat Breakfast", "🍖 Eat Lunch", "🍱 Eat Dinner"
    ) { feelingTired, breakfast, lunch, dinner in
      VStack(alignment: .leading) {
        TrackerPlotChart(
          (breakfast, .circle), (lunch, .circle), (dinner, .circle), (feelingTired, .asterisk),
          range: dateRange.startDate...dateRange.endDate,
          logDate: .both,
          granularity: dateRange.selectedDateWindow,
          width: .short,
          annotations: [],
          context: viewContext
        )
        Text("Do you feel sleepy shortly after eating?")
          .footer()
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

  func stuffyNose() -> some View {
    ATrackerView("👃 Stuffy Nose") { tracker in
      DidCompleteChart(tracker: tracker, negateColors: true)
    }
  }

  func nightlySnacks() -> some View {
    ATrackerView("Evening sleepy snacks") { tracker in
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
            .foregroundStyle(.white)
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

      DisclosureGroup {
        HistogramTable(tracker: tracker, fieldKey: "Workout")
      } label: {
        Text("View Workout Table")
      }
    }
  }

  func goToBed(includeExtraCharts: Bool = false) -> some View {
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

    @ViewBuilder
    func builder() -> some View {
      ATrackerView("Go To Bed", title: "💤 Go to bed") { tracker in
        DidCompleteChart(
          tracker: tracker,
          daily: { logs, _ in
            if logs.isEmpty {
              .gray.opacity(0.35)
            } else if logs.contains(where: matchesPredicate(log:)) {
              .green
            } else {
              .red
            }
          }, monthly: { logs in
            (logs.filter(matchesPredicate(log:)).count, 30)
          }, label: { logs, _ in
            if let log = logs.first(where: matchesPredicate(log:)), let timestamp = log.timestamp {
              Text(timestamp, format: .time)
                .font(.system(size: 6))
                .foregroundStyle(.white)
            } else if let first = logs.first, let timestamp = first.timestamp {
              Text(timestamp, format: .time)
                .font(.system(size: 6))
                .foregroundStyle(.white)
            } else {
              EmptyView()
            }
          }
        )
      }

      if includeExtraCharts {
        ManyTrackersView(trackerNames: "Go To Bed", "Go To Bed") { tracker, _ in
          TrackerPlotChart(
            (tracker, .circle),
            range: dateRange.startDate...dateRange.endDate,
            logDate: .start,
            granularity: dateRange.selectedDateWindow,
            width: .short,
            annotations: [],
            context: viewContext
          )
        }

        TrackerView("Go To Bed") { tracker in
          VStack(alignment: .leading) {
            DidCompleteChart(
              tracker: tracker,
              daily: { logs, _ in
                if logs.isEmpty {
                  .gray.opacity(0.35)
                } else if let log = logs.first {
                  if let sleepy = log.allValues.first(where: { $0.field?.title == "Feeling sleepy" })?.boolValue {
                    sleepy ? .green : .red
                  } else {
                    .clear
                  }
                } else {
                  .red
                }
              }, monthly: { logs in
                (logs.filter(matchesPredicate(log:)).count, 30)
              }, label: { logs, _ in
                if let log = logs.first {
                  if let sleepy = log.allValues.first(where: { $0.field?.title == "Feeling sleepy" })?.boolValue {
                    Text(sleepy ? "😴" : "😬")
                  } else {
                    Text("")
                  }
                }
              }
            )
            .frame(height: 38)
            Text("Feeling sleepy")
              .footer()
          }
        }
      }
    }

    return builder()
  }

  func getOutOfBed(includeExtraCharts: Bool = false) -> some View {
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

    @ViewBuilder
    func builder() -> some View {
      ATrackerView("Get Out Of Bed", title: "☀️ Get out of bed") { tracker in
        DidCompleteChart(
          tracker: tracker,
          daily: { logs, _ in
            if logs.isEmpty {
              .gray.opacity(0.35)
            } else if logs.contains(where: matchesPredicate(log:)) {
              .green
            } else {
              .red
            }
          }, monthly: { logs in
            (logs.filter(matchesPredicate(log:)).count, 30)
          }, label: { logs, _ in
            if let log = logs.first(where: matchesPredicate(log:)), let timestamp = log.timestamp {
              Text(timestamp, format: .time)
                .font(.system(size: 6))
                .foregroundStyle(.white)
            } else if let first = logs.first, let timestamp = first.timestamp {
              Text(timestamp, format: .time)
                .font(.system(size: 6))
                .foregroundStyle(.white)
            }
          }
        )
      }

      if includeExtraCharts {
        ManyTrackersView(trackerNames: "Get Out Of Bed", "Get Out Of Bed") { tracker, _ in
          TrackerPlotChart(
            (tracker, .circle),
            range: dateRange.startDate...dateRange.endDate,
            logDate: .start,
            granularity: dateRange.selectedDateWindow,
            width: .short,
            annotations: [],
            context: viewContext
          )
        }

        TrackerView("Get Out Of Bed") { tracker in
          VStack(alignment: .leading) {
            DidCompleteChart(
              tracker: tracker,
              daily: { logs, _ in
                if logs.isEmpty {
                  .gray.opacity(0.35)
                } else if let log = logs.first {
                  if let refreshed = log.allValues.first(where: { $0.field?.title == "Feel well rested" })?.boolValue {
                    refreshed ? .green : .red
                  } else {
                    .clear
                  }
                } else {
                  .red
                }
              }, monthly: { logs in
                (logs.filter(matchesPredicate(log:)).count, 30)
              }, label: { logs, _ in
                if let log = logs.first {
                  if let refreshed = log.allValues.first(where: { $0.field?.title == "Feel well rested" })?.boolValue {
                    Text(refreshed ? "😌" : "😪")
                  } else {
                    Text("")
                  }
                }
              }
            )
            .frame(height: 38)
            Text("Feeling fresh")
              .footer()
          }
        }
      }
    }

    return builder()
  }
}
