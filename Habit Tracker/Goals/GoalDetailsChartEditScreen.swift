//
//  GoalDetailsChartEditScreen.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/25/23.
//

import SwiftUI

struct GoalDetailsChartEditScreen: View {
  @ObservedObject var chart: GoalChart

  private let startDate: Date
  private let endDate: Date

  @State private var nameOverride: String

  @Environment(\.managedObjectContext)
  private var viewContext

  init(_ chart: GoalChart) {
    self.chart = chart

    let now = Date()
    let calendar = Calendar.current
    let sunday = calendar.date(
      from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
    )
    self.startDate = calendar.date(byAdding: .day, value: 0, to: sunday!)!
    self.endDate = startDate.addingTimeInterval(.init(days: 7))
    self._nameOverride = State(initialValue: chart.nameOverride ?? "")
  }

  var body: some View {
    List {
      Section {
        makeChart()
      }
      .listStyle(.insetGrouped)

      Section {
        HStack {
          Text("Chart Name")
          TextField(chart.tracker!.tracker!.title!, text: $nameOverride)
            .multilineTextAlignment(.trailing)
            .onSubmit {
              if nameOverride.isEmpty {
                chart.nameOverride = nil
              } else {
                chart.nameOverride = nameOverride
              }
              try! viewContext.save()
            }
            .submitLabel(.done)
        }
        Picker("Chart Type", selection: $chart.kind) {
          ForEach(ChartKind.allCases) { kind in
            Text(kind.stringValue).tag(kind)
          }
        }
        Picker("Chart Size", selection: $chart.height) {
          ForEach(ChartSize.allCases) { size in
            Text(size.stringValue).tag(size)
          }
        }
        Picker("Date to use", selection: $chart.logDate) {
          ForEach(ChartDate.allCases) { date in
            Text(date.stringValue).tag(date)
          }
        }
      }
      .listStyle(.grouped)
    }
    .navigationBarHeadline("Edit Chart", subheadline: "for \(chart.tracker!.tracker!.title!)")

    .onChange(of: chart.kind) { _ in
      try! viewContext.save()
    }
    .onChange(of: chart.height) { _ in
      try! viewContext.save()
    }
  }

  @ViewBuilder
  func makeChart() -> some View {
    HStack {
      Text(chart.nameOverride ?? chart.tracker!.tracker!.title!)
        .foregroundColor(.primary)
      Spacer()
      switch chart.kind {
      case .count:
        TrackerBarChart(
          chart.tracker!.tracker!,
          range: startDate...endDate,
          granularity: .week,
          context: viewContext
        )
        .frame(width: 196, height: chart.height.floatValue)
      case .frequency:
        TrackerPlotChart(
          chart.tracker!.tracker!,
          range: startDate...endDate,
          logDate: chart.logDate,
          granularity: .week,
          context: viewContext
        )
        .frame(width: 196, height: chart.height.floatValue)
      }
    }
  }
}
