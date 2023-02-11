//
//  GoalDetailsChartsScreen.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/16/23.
//

import Charts
import CoreData
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

  @StateObject private var dateRangePickerViewModel = DateRangePickerViewModel(intialDate: Date())

  init(_ goal: Goal) {
    self.goal = goal
    self._sections = FetchRequest(
      sortDescriptors: [SortDescriptor(\GoalChartSection.title)], // TODO: manual sorting
      predicate: NSPredicate(format: "goal = %@", goal)
    )
  }

  var body: some View {
    NavigationView {
      VStack {
        DateRangePicker(viewModel: dateRangePickerViewModel)
          .padding(.horizontal)

        List(sections) { section in
          Section(section.title!) {
            ChartSection(section, goal: goal)
          }
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
        GoalTrackerChartPickerScreen(
          title: "Select a Chart",
          subtitle: "Goal: \(goal.title!) Section: \(section.title!)",
          goal: goal
        ) { chart in
          switch chart {
          case .tracker(let tracker, let kind):
            withAnimation {
              let newChart = GoalChart(context: viewContext)
              newChart.tracker = tracker
              newChart.kind = kind
              section.addToCharts(newChart)

              try! viewContext.save()
            }
          case .chart:
            break
          }
        }
      }
    }
    .environmentObject(dateRangePickerViewModel)
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
      sortDescriptors: [SortDescriptor(\GoalChart.tracker!.tracker!.title!)], // TODO: manual sorting
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

  private func makeChartPicker<Label: View>(
    section: GoalChartSection,
    goal: Goal,
    context: NSManagedObjectContext,
    @ViewBuilder label: () -> Label
  ) -> some View {
    SheetLink {
      GoalTrackerChartPickerScreen(
        title: "Select a Chart",
        subtitle: "Goal: \(goal.title!) Section: \(section.title!)",
        goal: goal
      ) { chart in
        switch chart {
        case .tracker(let tracker, let kind):
          withAnimation {
            let newChart = GoalChart(context: context)
            newChart.tracker = tracker
            newChart.kind = kind
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
}

private struct ChartCell: View {
  @ObservedObject private var chart: GoalChart
  @ObservedObject private var tracker: Tracker

  @EnvironmentObject private var picker: DateRangePickerViewModel

  @State private var showEditorForChart: GoalChart?

  @Environment(\.managedObjectContext)
  private var viewContext

  init(_ chart: GoalChart) {
    self.chart = chart
    self.tracker = chart.tracker!.tracker!
  }

  var body: some View {
    SheetLink {
      TrackerDetailScreen(tracker)
    } label: {
      HStack {
        Text(chart.tracker!.tracker!.title!)
          .foregroundColor(.primary)
        Spacer()

        switch chart.kind {
        case .count:
          TrackerBarChart(
            chart.tracker!.tracker!,
            range: picker.startDate...picker.endDate,
            granularity: picker.selectedDateWindow,
            context: viewContext
          )
          .frame(width: 196, height: chart.height.floatValue)
        case .frequency:
          TrackerPlotChart(
            chart.tracker!.tracker!,
            range: picker.startDate...picker.endDate,
            granularity: picker.selectedDateWindow,
            context: viewContext
          )
          .frame(width: 196, height: chart.height.floatValue)
        }
      }
      .contextMenu {
        Button(action: { addLog(for: chart.tracker!.tracker!) }, title: "Add log", systemImage: "plus")
        Button(action: { showEditorForChart = chart }, title: "Edit Chart", systemImage: "pencil")
      }
      .sheet(item: $showEditorForChart) { chart in
        NavigationView {
          GoalDetailsChartEditScreen(chart)
        }
      }
    }
  }

  private func addLog(for tracker: Tracker) {
    let newLog = TrackerLog(context: viewContext)
    newLog.timestamp = Date()
    tracker.addToLogs(newLog)

    try! viewContext.save()
  }
}
