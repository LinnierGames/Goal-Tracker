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

  @FetchRequest
  private var annotations: FetchedResults<GoalChartAnnotation>

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
    self._annotations = FetchRequest(
      sortDescriptors: [],
      predicate: NSPredicate(format: "chart = %@", chart)
    )
  }

  var body: some View {
    List {
      Section {
        makeChart()
      }

      makeGeneralSettings()
      makeAnnotationsSettings()
    }
    .listStyle(.insetGrouped)
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
          annotations: chart.allAnnotations,
          context: viewContext
        )
        .frame(width: 196, height: chart.height.floatValue)
      }
    }
  }

  @ViewBuilder
  func makeGeneralSettings() -> some View {
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
  }

  @ViewBuilder
  func makeAnnotationsSettings() -> some View {
    Section {
      ForEach(annotations) { annotation in
        NavigationLink {
          GoalDetailsChartEditAnnotationDetailScreen(annotation, chart: chart, startDate: startDate, endDate: endDate)
        } label: {
          HStack {
            Text(annotation.kind.stringValue)

            Spacer()

            if let value = annotation.xValue?.stringValue {
              Text("X: \(value)")
                .foregroundColor(.gray)
            }
            if let value = annotation.yValue?.stringValue {
              Text("Y: \(value)")
                .foregroundColor(.gray)
            }
          }
        }
        .swipeActions {
          Button(role: .destructive) {
            viewContext.delete(annotation)
            try! viewContext.save()
          } label: {
            Text("Delete")
          }

        }
      }
      Button {
        let new = GoalChartAnnotation(context: viewContext)
        new.kind = .line
        new.chart = chart
        try! viewContext.save()
      } label: {
        HStack {
          Text("Add annotation")
          Spacer()
        }
      }
    }
  }
}

struct GoalDetailsChartEditAnnotationDetailScreen: View {
  @ObservedObject var annotation: GoalChartAnnotation
  @ObservedObject var chart: GoalChart

  private let startDate: Date
  private let endDate: Date

  @Environment(\.managedObjectContext)
  private var viewContext

  init(_ annotation: GoalChartAnnotation, chart: GoalChart, startDate: Date, endDate: Date) {
    self.annotation = annotation
    self.chart = chart
    self.startDate = startDate
    self.endDate = endDate
  }

  private var showXValue: Bool {
    switch annotation.kind {
    case .line:
      return false
    case .point:
      return true
    }
  }

  private var showYValue: Bool {
    switch annotation.kind {
    case .line, .point:
      return true
    }
  }

  private var xValue: Binding<Decimal> {
    $annotation.xValue
      .mapOptional(defaultValue: 0)
      .map(get: { $0.decimalValue }, set: { NSDecimalNumber(decimal: $0) })
  }

  private var yValue: Binding<Decimal> {
    $annotation.yValue
      .mapOptional(defaultValue: 0)
      .map(get: { $0.decimalValue }, set: { NSDecimalNumber(decimal: $0) })
  }

  var body: some View {
    List {
      Section {
        switch chart.kind {
        case .count:
          TrackerBarChart(
            chart.tracker!.tracker!,
            range: startDate...endDate,
            granularity: .week,
            context: viewContext
          )
          .frame(height: ChartSize.large.floatValue)
        case .frequency:
          TrackerPlotChart(
            chart.tracker!.tracker!,
            range: startDate...endDate,
            logDate: chart.logDate,
            granularity: .week,
            annotations: chart.allAnnotations,
            context: viewContext
          )
          .frame(height: ChartSize.large.floatValue)
        }
      }

      Section {
        Picker("Kind", selection: $annotation.kind) {
          ForEach(GoalChartAnnotationKind.allCases) { kind in
            Text(kind.stringValue).tag(kind)
          }
        }

        if showXValue {
          HStack {
            Text("X value")
            TextField("", value: xValue, format: .number)
              .multilineTextAlignment(.trailing)
              .submitLabel(.done)
              .onSubmit {
                try! viewContext.save()
              }
          }
        }

        if showYValue {
          HStack {
            Text("Y value")
            TextField("", value: yValue, format: .number)
              .multilineTextAlignment(.trailing)
              .submitLabel(.done)
              .onSubmit {
                try! viewContext.save()
              }
          }
        }
      }
    }
    .toolbar {
      ToolbarItem(placement: .principal) {
        VStack {
          Text("Annotations").font(.headline)
          Text("for \(chart.tracker!.tracker!.title!)").font(.subheadline)
        }
      }
    }

    .onChange(of: annotation.kind) { _ in
      try! viewContext.save()
    }
  }
}
