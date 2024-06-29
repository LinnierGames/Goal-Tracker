//
//  GoalDashboardsScreen+Tabs.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 4/28/24.
//

import Charts
import SwiftUI

let BasicPlotSymbol = BasicChartSymbolShape.circle

extension GoalDashboardsScreen {
  func chickieTab() -> some View {
    VStack {
      Text("Chickie!")
        .font(.title2)

      Form {
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
          }
        }
      }
      .safeAreaPadding(.bottom, 72)
    }
  }

  func feelingEnergizedTab() -> some View {
    VStack {
      Text("Feeling Energized")
        .font(.title2)

      Form {
        Section {
//          ManyTrackersView(
//            trackerNames: "Breakfast", "Lunch", "Dinner", "Fast Food"
//          ) { breakfast, lunch, dinner, fastFood in
//            TrackerPlotChart(
//              (breakfast, { BasicPlotSymbol.erasedToAnyView() }),
//              (lunch, { BasicPlotSymbol.erasedToAnyView() }),
//              (dinner, { BasicPlotSymbol.erasedToAnyView() }),
//              (fastFood, { BasicPlotSymbol.erasedToAnyView() }),
//              range: dateRange.startDate...dateRange.endDate,
//              logDate: .both,
//              granularity: dateRange.selectedDateWindow,
//              width: .short,
//              annotations: [],
//              context: viewContext
//            )
//          }

          getOutOfBed(includeExtraCharts: true)
          goToBed(includeExtraCharts: true)
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
          feelingTiredDuringMeals()
        } header: {
          Text("Results")
        }
      }
      .safeAreaPadding(.bottom, 72)
    }
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
      .safeAreaPadding(.bottom, 72)
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
      .safeAreaPadding(.bottom, 72)
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
    }
  }

  @ViewBuilder
  func feelingTiredDuringMeals() -> some View {
    ManyTrackersView(
      trackerNames: "🥱 Feeling Tired", "🍔 Eat Breakfast", "🍖 Eat Lunch", "🍱 Eat Dinner"
    ) { feelingTired, breakfast, lunch, dinner in
      TrackerPlotChart(
        (breakfast, .circle), (lunch, .circle), (dinner, .circle), (feelingTired, .asterisk),
        range: dateRange.startDate...dateRange.endDate,
        logDate: .both,
        granularity: dateRange.selectedDateWindow,
        width: .short,
        annotations: [],
        context: viewContext
      )
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
            } else if let first = logs.first, let timestamp = first.timestamp {
              Text(timestamp, format: .time)
                .font(.system(size: 6))
            } else {
              EmptyView()
            }
          }
        )
      }

      if includeExtraCharts {
        TrackerView("Go To Bed") { tracker in
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
            } else if let first = logs.first, let timestamp = first.timestamp {
              Text(timestamp, format: .time)
                .font(.system(size: 6))
            }
          }
        )
      }

      if includeExtraCharts {
        TrackerView("Get Out Of Bed") { tracker in
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
        }
      }
    }

    return builder()
  }
}
