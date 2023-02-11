//
//  Date+Extensions.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/15/23.
//

import Foundation

extension Date {
  var midnight: Date {
    Calendar.current.startOfDay(for: self)
  }

  func set(
    second: Int? = nil,
    minute: Int? = nil,
    hour: Int? = nil,
    day: Int? = nil,
    month: Int? = nil,
    year: Int? = nil
  ) -> Date {
    var components = Calendar.current.dateComponents([.second, .minute, .hour, .day, .month, .year, .calendar], from: self)

    if let second {
      components.second = second
    }

    if let minute {
      components.minute = minute
    }

    if let hour {
      components.hour = hour
    }

    if let day {
      components.day = day
    }

    if let month {
      components.month = month
    }

    if let year {
      components.year = year
    }

    guard let date = components.date else {
      assertionFailure()
      return self
    }

    return date
  }
}
