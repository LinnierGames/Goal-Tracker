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
        Button(action: { isNewChartSectionAlertShowing = true }, systemImage: "plus")
      }

      .alert("Add Section", isPresented: $isNewChartSectionAlertShowing, actions: {
        TextField("Title", text: $newChartSectionTitle)
        Button("Cancel", role: .cancel, action: {})
        Button("Add", action: addNewChartSection)
      }, message: {
        Text("enter the title for your new goal")
      })
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
  @ObservedObject var chart: GoalChart

  private var startDate: Date
  private var endDate: Date

  @Environment(\.managedObjectContext)
  private var viewContext

  init(_ chart: GoalChart) {
    self.chart = chart

    let now = Date()
    let calendar = Calendar.current
    let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))

    self.startDate = calendar.date(byAdding: .day, value: 0, to: sunday!)!
    self.endDate = startDate.addingTimeInterval(.init(days: 7))
  }

  var body: some View {
    HStack {
      Text(chart.habit!.habit!.title!) // TODO: remove habit name
      Spacer()
      HabitChart(
        chart.habit!.habit!,
        range: startDate...endDate,
        granularity: .days,
        context: viewContext
      )
      .frame(width: 196, height: 64)
    }
  }
}

private struct ChartSection: View {
  var goal: Goal
  @ObservedObject var section: GoalChartSection

  @Environment(\.managedObjectContext)
  private var viewContext

  init(_ section: GoalChartSection, goal: Goal) {
    self.section = section
    self.goal = goal
  }

  var body: some View {
    if section.allCharts.isEmpty {
      makeChartPicker(section: section) {
        HStack {
          Spacer()
          VStack(alignment: .center, spacing: 8) {
            Text("No charts in the section!")
            Label("Add Chart", systemImage: "chart.bar")
          }
          Spacer()
        }
      }
    } else {
      ForEach(section.allCharts) { chart in
        ChartCell(chart)
      }
      makeChartPicker(section: section) {
        HStack {
          Spacer()
          Label("Add Chart", systemImage: "chart.bar")
          Spacer()
        }
      }
    }
  }

  private func makeChartPicker<Label: View>(
    section: GoalChartSection,
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
            let newChart = GoalChart(context: viewContext)
            newChart.habit = habit
            section.addToCharts(newChart)

            try! viewContext.save()
          }
        case .chart:
          break
        }
      }
    } label: {
      label()
    }
  }
}
