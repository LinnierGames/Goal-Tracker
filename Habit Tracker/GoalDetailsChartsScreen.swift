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
  private var habitCriterias: FetchedResults<GoalHabitCriteria>

  @Environment(\.managedObjectContext)
  private var viewContext

  init(_ goal: Goal) {
    self.goal = goal
    self._habitCriterias = FetchRequest(
      sortDescriptors: [SortDescriptor(\GoalHabitCriteria.habit!.title)],
      predicate: NSPredicate(format: "goal = %@", goal)
    )
  }

  var body: some View {
    NavigationView {
      List(goal.allChartSections) { section in
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

  private func addChart(to section: GoalChartSection) {

  }

  private func addNewChartSection() {
    withAnimation {
      let newSection = GoalChartSection(context: viewContext)
      newSection.title = newChartSectionTitle
      goal.addToChartSections(newSection)

      try! viewContext.save()
    }
  }
}

struct ChartCell: View {
  @ObservedObject var chart: GoalChart

  init(_ chart: GoalChart) {
    self.chart = chart
  }

  var body: some View {
    Chart {
      LineMark(x: .value("x", "12 pm"), y: .value("count", 5))
      LineMark(x: .value("x", "1"), y: .value("count", 8))
      LineMark(x: .value("x", "2"), y: .value("count", 15))
      LineMark(x: .value("x", "3"), y: .value("count", 2))
    }
    .padding(.vertical)
  }
}

struct ChartSection: View {
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

struct GoalHabitChartPickerScreen: View {
  let title: String
  let subtitle: String
  let goal: Goal

  enum Chart {
    case habit(GoalHabitCriteria)
    case chart(Void) // TODO: Reference simple charts from the habit itself
  }
  let didPick: (Chart) -> Void

  @FetchRequest
  private var criterias: FetchedResults<GoalHabitCriteria>

  @Environment(\.dismiss) var dismiss

  init(title: String, subtitle: String, goal: Goal, didPick: @escaping (Chart) -> Void) {
    self.title = title
    self.subtitle = subtitle
    self.goal = goal
    self.didPick = didPick
    self._criterias = FetchRequest(
      sortDescriptors: [SortDescriptor(\GoalHabitCriteria.habit!.title)],
      predicate: NSPredicate(format: "goal = %@", goal)
    )
  }

  var body: some View {
    NavigationView {
      List(criterias) { criteria in
        HStack {
          Text(criteria.habit!.title!)
          Spacer()
          Button {
            didPick(.habit(criteria))
            dismiss()
          } label: {
            Text("New Chart")
              .font(.caption)
          }
          .buttonStyle(.bordered)
        }
        .contentShape(Rectangle())
        .onTapGesture {
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          VStack {
            Text(title).font(.headline)
            Text(subtitle).font(.subheadline)
          }
        }
      }
    }
  }
}
