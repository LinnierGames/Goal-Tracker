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

  var body: some View {
    TrackerLogView(
      tracker: tracker,
      range: range.lowerBound...range.upperBound
    ) { logs in
      let histogram = histogram(logs).reduce(into: [String: Int]()) { partialResult, restaurant in
        partialResult[restaurant, default: 0] += 1
      }.map { $0 }.sorted(by: \.value, order: .reverse)

      ScrollView(.vertical) {
        Chart {
          ForEach(histogram, id: \.key) { key, value in
            BarMark(
              x: .value("value", value),
              y: .value("key", key)
            )
          }
        }
        .frame(height: 48 * CGFloat(histogram.count))
      }
    }
  }
}
