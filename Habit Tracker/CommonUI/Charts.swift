//
//  Charts.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/19/23.
//

import Charts
import SwiftUI

struct RandomChart: View {
  enum Style {
    case line, bar
  }
  let style: Style

  init(_ style: Style) {
    self.style = style
  }

  var body: some View {
    Chart {
      switch style {
      case .line:
        LineMark(x: .value("x", "12 pm"), y: .value("count", (0..<10).randomElement()!))
        LineMark(x: .value("x", "1"), y: .value("count", (0..<10).randomElement()!))
        LineMark(x: .value("x", "2"), y: .value("count", (0..<10).randomElement()!))
        LineMark(x: .value("x", "3"), y: .value("count", (0..<10).randomElement()!))
      case .bar:
        BarMark(x: .value("x", "12 pm"), y: .value("count", (0..<10).randomElement()!))
        BarMark(x: .value("x", "1"), y: .value("count", (0..<10).randomElement()!))
        BarMark(x: .value("x", "2"), y: .value("count", (0..<10).randomElement()!))
        BarMark(x: .value("x", "3"), y: .value("count", (0..<10).randomElement()!))
      }
    }
    .chartXAxis(.hidden)
    .chartYAxis(.hidden)
    .background(Color.gray.opacity(0.25))
  }
}
