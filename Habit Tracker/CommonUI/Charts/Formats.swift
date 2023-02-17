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
  enum Format: Hashable, Codable {
    enum HourOfTheDay: Hashable, Codable {
      case full
      case minized
    }
    case hourOfTheDay(style: HourOfTheDay = .full)
    case dayOfTheWeek
    case dayOfTheMonth

    enum MonthOfTheYear: Hashable, Codable {
      case short, medium, full
    }
    case monthOfTheYear(style: MonthOfTheYear)
  }
  private let format: Format

  init(_ format: Format) {
    self.format = format
  }

  func format(_ value: Date) -> String {
    let formatter = DateFormatter()
    switch format {
    case .hourOfTheDay(let configuration):
      formatter.dateFormat = "H"
      let string = formatter.string(from: value)
      switch configuration {
      case .full:
        return string
      case .minized:
        if ["0", "6", "12", "18"].contains(string) {
          return string
        } else {
          return ""
        }
      }
    case .dayOfTheWeek:
      formatter.dateFormat = "EEEEE"
      return formatter.string(from: value)
    case .dayOfTheMonth:
      formatter.dateFormat = "d"
      return formatter.string(from: value)
    case .monthOfTheYear(let style):
      switch style {
      case .short:
        formatter.dateFormat = "MMMMM"
        return formatter.string(from: value)
      case .medium:
        formatter.dateFormat = "MMM"
        return formatter.string(from: value)
      case .full:
        formatter.dateFormat = "MMMM"
        return formatter.string(from: value)
      }
    }
  }
}
