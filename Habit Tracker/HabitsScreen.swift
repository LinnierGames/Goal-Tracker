//
//  HabbitsScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/14/23.
//

import SwiftUI

struct SheetLink<Destination: View, Label: View>: View {
  let destination: Destination
  let label: Label

  @State private var isShowingSheet = false

  init(@ViewBuilder destination: () -> Destination, @ViewBuilder label: () -> Label) {
    self.destination = destination()
    self.label = label()
  }

  var body: some View {
    label
      .contentShape(Rectangle())
      .onTapGesture {
        isShowingSheet.toggle()
      }
      .sheet(isPresented: $isShowingSheet) {
        destination
      }
  }
}

struct HabitsScreen: View {
  @Environment(\.managedObjectContext) private var viewContext

  @FetchRequest(sortDescriptors: [SortDescriptor(\Habit.title)])
  private var items: FetchedResults<Habit>

  var body: some View {
    NavigationView {
      List(items) { habit in
        SheetLink {
          HabitDetailScreen(habit)
        } label: {
          HStack {
            VStack(alignment: .leading) {
              Text(habit.title ?? "Untitled")
              Text(habit.entries?.allObjects.count ?? 0, format: .number)
            }
            Spacer()
            Image(systemName: "chevron.right")
          }
        }
      }
      .navigationTitle("Habits")
    }
  }
}

struct HabitDetailScreen: View {
  @StateObject var habit: Habit
  @State var uiTabarController: UITabBarController?

  init(_ habit: Habit) {
    self._habit = StateObject(wrappedValue: habit)
  }

  var body: some View {
    TabView {
      HabitDetailsChartScreen(habit: habit)
        .tabItem {
          Label("Analytics", systemImage: "chart.xyaxis.line")
        }

      HabitDetailsHistoryScreen(habit: habit)
        .tabItem {
          Label("History", systemImage: "clock.arrow.circlepath")
        }

      NavigationView {
        Text("HI")
          .navigationTitle(habit.title!)
      }
      .tabItem {
        Label("Habit", systemImage: "figure.walk")
      }
    }
  }
}

import Charts
import MetricKit

struct HabitDetailsChartScreen: View {
  @ObservedObject var habit: Habit

  @StateObject private var viewModel = HabitDetailsChartViewModel()

  @FetchRequest
  private var entries: FetchedResults<HabitEntry>

  @Environment(\.managedObjectContext) private var viewContext

  init(habit: Habit) {
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
        switch viewModel.selectedDateWindow {
        case .day:
          makeDayView()
        case .week:
          makeWeekView()
        case .month:
          makeMonthView()
        case .year:
          makeYearView()
        }

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

  private func makeDayView() -> some View {
    let hour = TimeInterval(hours: 1)
    let data = stride(from: viewModel.startDate, to: viewModel.endDate, by: hour)
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
        formatter.dateFormat = "HH"
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

  private struct Data: Identifiable {
    var id: String { timestamp }

    let timestamp: String
    let count: Int
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
        formatter.dateFormat = "yyyy-MM-dd"
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
        formatter.dateFormat = "yyyy-MM-dd"
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
  @Published var selectedDate = Date(timeIntervalSince1970: 1557973862)

  var selectedDateLabel: String {
    String(describing: selectedDate)
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

struct HabitDetailsHistoryScreen: View {
  @ObservedObject var habit: Habit

  @FetchRequest
  var entries: FetchedResults<HabitEntry>

  init(habit: Habit) {
    self.habit = habit
    self._entries = FetchRequest(
      sortDescriptors: [SortDescriptor(\HabitEntry.timestamp)],
      predicate: NSPredicate(format: "habit = %@", habit)
    )
  }

  var body: some View {
    NavigationView {
      List {
        Section("Entries") {
          ForEach(entries) { entry in
            Text("\(entry.timestamp!, style: .date) at \(entry.timestamp!, style: .time)")
          }
        }
      }
      .navigationBarTitleDisplayMode(.large)
      .navigationTitle(habit.title!)
    }
  }
}

import CoreData

struct ImportDataScreen: View {
  @State private var stagedURLs = [URL]()
  @Environment(\.managedObjectContext) var viewContext

  var body: some View {
    VStack {
      List {
        Section("Habits") {
          FilePicker(types: [.commaSeparatedText], allowMultiple: false) { urls in
            stageFiles(urls: urls)
          } label: {
            HStack {
              Image(systemName: "doc.on.doc")
              Text("Pick File")
            }
          }
          if !stagedURLs.isEmpty {
            ForEach(stagedURLs, id: \.self) { url in
              Text(url.lastPathComponent)
            }
            .onDelete { index in
              stagedURLs.remove(at: index.first!)
            }
          }
        }

        Section("Sleep") {

        }

        Section("Blocks") {

        }

        Section("Calory") {

        }
      }

      ButtonFill("Import", fill: .blue) {
        importHabits(url: stagedURLs[0])
      }
      .disabled(stagedURLs.isEmpty)
    }
  }

  private func stageFiles(urls: [URL]) {
    stagedURLs = urls
  }

  private func importHabits(url: URL) {
    guard
      let data = try? Data(contentsOf: url),
      let content = String(data: data, encoding: .utf8)
    else {
      return
    }

    struct CSV {
      let headers: [String]

      struct Row {
        let columns: [String]
      }
      let rows: [Row]
    }

    func findItOrCreateIt<T: NSManagedObject>(
      fetch: NSFetchRequest<T>,
      predicate: () -> NSPredicate,
      createIt: () -> T
    ) -> T {
      do {
        fetch.predicate = predicate()
        let result = try viewContext.fetch(fetch)

        if let it = result.first {
          return it
        } else {
          return createIt()
        }
      } catch {
        assertionFailure(error.localizedDescription)

        return createIt()
      }
    }

    func findHabitOrCreateIt(title: String) -> Habit {
      findItOrCreateIt(fetch: Habit.fetchRequest()) {
        NSPredicate(format: "title = %@", title)
      } createIt: {
        let new = Habit(context: viewContext)
        new.title = title
        return new
      }
    }

    func findTimestampOrCreateIt(date: Date, habitTitle: String) -> HabitEntry {
      findItOrCreateIt(fetch: HabitEntry.fetchRequest()) {
        NSPredicate(format: "timestamp = %@ AND habit.title = %@", date as NSDate, habitTitle)
      } createIt: {
        let new = HabitEntry(context: viewContext)
        new.timestamp = date
        return new
      }
    }

    let stringRows = content.components(
      separatedBy: "\n"
    )
    let rows = Array(
      stringRows.map { CSV.Row(columns: $0.components(separatedBy: ",")) }.dropFirst()
    )
    let headers = stringRows[0].split(separator: ",").map(String.init)

    let csv = CSV(headers: headers, rows: rows)

    guard
      let trackerIndex = csv.headers.firstIndex(of: "Tracker"),
      let timestampIndex = csv.headers.firstIndex(of: "Date (ISO 8601)")
    else {
      fatalError()
    }

    for row in csv.rows {
      guard
        row.columns.indices.contains(trackerIndex),
        row.columns.indices.contains(timestampIndex)
      else {
        continue
      }

      let tracker = row.columns[trackerIndex]
      let timestampString = row.columns[timestampIndex]

      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
      let timestamp = formatter.date(from: timestampString)!

      let habit = findHabitOrCreateIt(title: tracker)
      let entry = findTimestampOrCreateIt(date: timestamp, habitTitle: tracker)

      habit.addToEntries(entry)
    }

    try! viewContext.save()
  }
}

struct GoalsScreen: View {
  var body: some View {
    Text("Goals")
  }
}
