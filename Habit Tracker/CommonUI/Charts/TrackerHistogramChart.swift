//
//  TrackerHistogramChart.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 4/26/24.
//

import Charts
import SwiftUI

struct HistogramChart: View {
  @ObservedObject var tracker: Tracker
  let range: ClosedRange<Date>
  let histogram: (FetchedResults<TrackerLog>) -> [String]

  init(
    _ tracker: Tracker,
    range: ClosedRange<Date>,
    histogram: @escaping (FetchedResults<TrackerLog>) -> [String]
  ) {
    self.tracker = tracker
    self.range = range
    self.histogram = histogram
  }

  var body: some View {
    TrackerLogView(
      tracker: tracker,
      range: range.lowerBound...range.upperBound
    ) { logs in
      let histogram = histogram(logs).reduce(into: [String: Int]()) {
        $0[$1, default: 0] += 1
      }.map { $0 }.sorted(by: \.value, order: .reverse)

      ScrollView(.vertical) {
        Chart {
          ForEach(histogram, id: \.key) { key, value in
            BarMark(
              x: .value("value", value),
              y: .value("key", key)
            )
            .annotation(position: .automatic, alignment: .trailing) {
              Text(value, format: .number)
                .font(.caption)
                .padding(.horizontal, 10)
                .foregroundStyle(.white)
            }
          }
        }
        .frame(height: 48 * CGFloat(histogram.count))
      }
    }
  }
}

struct HistogramTable: View {
  @ObservedObject var tracker: Tracker
  let fieldKey: String
  let negateColors: Bool

  @EnvironmentObject var datePicker: DateRangePickerViewModel

  init(
    tracker: Tracker,
    fieldKey: String,
    negateColors: Bool = false
  ) {
    self.tracker = tracker
    self.fieldKey = fieldKey
    self.negateColors = negateColors
  }

  var body: some View {
    TrackerLogView(tracker: tracker, range: datePicker.startDate...datePicker.endDate) { logs in
      let uniqueFieldValues = logs.compactMap { log in
        log.allValues.first(where: {
          $0.field?.title == fieldKey
        })?.string.sanitize(.capitalized, .whitespaceTrimmed)
      }.reduce(into: Set()) { histogram, fieldValue in
        histogram.insert(fieldValue)
      }.sorted(by: \.self)

      ForEach(uniqueFieldValues, id: \.self) { fieldValue in
        VStack(alignment: .leading) {
          Text(fieldValue)
          DidCompleteChart(
            tracker: tracker
          ) { logs, _ in
            if filter(forFieldValue: fieldValue, fieldKey: fieldKey, logs).isEmpty {
              .clear
            } else {
              negateColors ? .red : .green
            }
          } monthly: { logs in
            (filter(forFieldValue: fieldValue, fieldKey: fieldKey, logs).count, 30)
          } label: { logs, _ in
            let numberOfLogs = filter(forFieldValue: fieldValue, fieldKey: fieldKey, logs).count

            if numberOfLogs > 1 {
              Text(
                numberOfLogs,
                format: .number
              )
              .foregroundStyle(.white)
            }
          }
        }
      }
      .padding(.vertical)
    }
  }

  private func filter<Logs: Collection>(
    forFieldValue fieldValue: String,
    fieldKey: String,
    _ logs: Logs
  ) -> [TrackerLog] where Logs.Element == TrackerLog {
    logs.filter { log in
      log.allValues.first(where: {
        $0.field?.title == fieldKey
      })?.string.sanitize(.capitalized, .whitespaceTrimmed) == fieldValue
    }
  }
}
