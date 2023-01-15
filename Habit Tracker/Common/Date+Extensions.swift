//
//  Date+Extensions.swift
//  Habit Tracker
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
    hour: Int? = nil
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

    guard let date = components.date else {
      assertionFailure()
      return self
    }

    return date
  }
}
