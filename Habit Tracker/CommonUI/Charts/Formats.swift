//
//  Formats.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/26/23.
//

import Foundation

struct ChartHourFormat: FormatStyle {
  func format(_ value: Int) -> String {
    if value >= 12 {
      if value > 12 {
        return "\(value - 12)p"
      } else {
        return "12p"
      }
    } else {
      if value == 12 {
        return "12a"
      } else {
        return "\(value)a"
      }
    }
  }
}

struct ChartDayFormat: FormatStyle {
  func format(_ value: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd"
    return formatter.string(from: value)
  }
}
