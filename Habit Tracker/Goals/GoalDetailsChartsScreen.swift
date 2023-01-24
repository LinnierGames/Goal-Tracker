//
//  GoalDetailsChartsScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/16/23.
//

import Charts
import SwiftUI

struct GoalDetailsChartsScreen: View {
  @ObservedObject var goal: Goal

  @State private var isNewChartSectionAlertShowing = false
  @State private var newChartSectionTitle = ""
  @State private var addNewChartToSection: GoalChartSection?

  @FetchRequest
  private var sections: FetchedResults<GoalChartSection>

  @Environment(\.managedObjectContext)
  private var viewContext

  init(_ goal: Goal) {
    self.goal = goal
    self._sections = FetchRequest(
      sortDescriptors: [SortDescriptor(\GoalChartSection.title)], // TODO: manual sorting
      predicate: NSPredicate(format: "goal = %@", goal)
    )
  }

  var body: some View {
    NavigationView {
      List(sections) { section in
        Section(section.title!) {
          ChartSection(section, goal: goal)
        }
      }
      .navigationTitle(goal.title!)
      .toolbar {
        Menu {
          Button(
            action: { isNewChartSectionAlertShowing = true },
            title: "Add Section", systemImage: "plus"
          )

          Menu {
            ForEach(sections) { section in
              Button(section.title!) {
                addNewChartToSection = section
              }
            }
          } label: {
            Label("Add Chart", systemImage: "chart.xyaxis.line")
          }
        } label: {
          Image(systemName: "plus")
        }

        SheetLink {
          GoalDetailsChartsEditScreen(goal)
        } label: {
          Text("Edit")
        }
      }

      .alert("Add Section", isPresented: $isNewChartSectionAlertShowing, actions: {
        TextField("Title", text: $newChartSectionTitle)
        Button("Cancel", role: .cancel, action: {})
        Button("Add", action: addNewChartSection)
      }, message: {
        Text("enter the title for your new goal")
      })

      .sheet(item: $addNewChartToSection) { section in
        GoalHabitChartPickerScreen(
          title: "Select a Chart",
          subtitle: "Goal: \(goal.title!) Section: \(section.title!)",
          goal: goal
        ) { chart in
          switch chart {
          case .habit(let habit):
            withAnimation {
              let newChart = GoalChart(context: viewContext)
              newChart.habit = habit
              section.addToCharts(newChart)

              try! viewContext.save()
            }
          case .chart:
            break
          }
        }
      }
    }
  }

  private func addNewChartSection() {
    withAnimation {
      let newSection = GoalChartSection(context: viewContext)
      newSection.title = newChartSectionTitle
      goal.addToChartSections(newSection)

      try! viewContext.save()

      newChartSectionTitle = ""
    }
  }
}

private struct ChartCell: View {
  @ObservedObject private var chart: GoalChart
  @ObservedObject private var tracker: Habit

  private var startDate: Date
  private var endDate: Date

  @Environment(\.managedObjectContext)
  private var viewContext

  init(_ chart: GoalChart) {
    self.chart = chart
    self.tracker = chart.habit!.habit!

    let now = Date()
    let calendar = Calendar.current
    let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))

    self.startDate = calendar.date(byAdding: .day, value: 0, to: sunday!)!
    self.endDate = startDate.addingTimeInterval(.init(days: 7))
  }

  var body: some View {
    SheetLink {
      HabitDetailScreen(tracker)
    } label: {
      HStack {
        Text(chart.habit!.habit!.title!) // TODO: remove habit name
          .foregroundColor(.primary)
        Spacer()
        HabitChart(
          chart.habit!.habit!,
          range: startDate...endDate,
          granularity: .days,
          context: viewContext
        )
        .frame(width: 196, height: 64)
      }
      .contextMenu {
        Button(action: { addLog(for: chart.habit!.habit!) }, title: "Add log", systemImage: "plus")
      }
    }
  }

  private func addLog(for tracker: Habit) {
    let newLog = HabitEntry(context: viewContext)
    newLog.timestamp = Date()
    tracker.addToEntries(newLog)

    try! viewContext.save()
  }
}

private struct ChartSection: View {
  var goal: Goal
  @ObservedObject var section: GoalChartSection

  @FetchRequest
  private var charts: FetchedResults<GoalChart>

  @Environment(\.managedObjectContext)
  private var viewContext

  // FIXME: for some reason, deleting charts or sections causes a crash originating from this view

  init(_ section: GoalChartSection, goal: Goal) {
    self.section = section
    self.goal = goal
    self._charts = FetchRequest(
      sortDescriptors: [SortDescriptor(\GoalChart.habit!.habit!.title!)], // TODO: manual sorting
      predicate: NSPredicate(format: "section = %@", section)
    )
  }

  var body: some View {
    if charts.isEmpty {
      makeChartPicker(section: section, goal: goal, context: viewContext) {
        HStack {
          Spacer()
          VStack(alignment: .center, spacing: 8) {
            Text("No charts in the section!")
              .foregroundColor(.primary)
            Label("Add a Chart", systemImage: "chart.bar")
          }
          Spacer()
        }
      }
    } else {
      ForEach(charts) { chart in
        ChartCell(chart)
      }
    }
  }
}

import CoreData

private func makeChartPicker<Label: View>(
  section: GoalChartSection,
  goal: Goal,
  context: NSManagedObjectContext,
  @ViewBuilder label: () -> Label
) -> some View {
  SheetLink {
    GoalHabitChartPickerScreen(
      title: "Select a Chart",
      subtitle: "Goal: \(goal.title!) Section: \(section.title!)",
      goal: goal
    ) { chart in
      switch chart {
      case .habit(let habit):
        withAnimation {
          let newChart = GoalChart(context: context)
          newChart.habit = habit
          section.addToCharts(newChart)

          try! context.save()
        }
      case .chart:
        break
      }
    }
  } label: {
    label()
  }
}
