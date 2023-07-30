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

  var startOfWeek: Date {
    let gregorian = Calendar(identifier: .gregorian)
    guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { fatalError() }
    return gregorian.date(byAdding: .day, value: 1, to: sunday)!
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

  // today, yesterday, 2 days ago, x days ago, a week ago, x weeks ago, a month ago, x months ago, a year ago
  var timeAgo: String {
    let calendar = Calendar.current
    let now = Date()

    if calendar.isDateInToday(self) {
      return "Today"
    }

    if calendar.isDateInYesterday(self) {
      return "Yesterday"
    } else if self < now {
      let components = calendar.dateComponents([.day, .weekOfYear, .month, .year], from: self, to: now)
      if components.year ?? 0 > 0 {
        if components.year == 1 {
          return "A year ago"
        } else {
          return "\(components.year!) years ago"
        }
      } else if components.month ?? 0 > 0 {
        if components.month == 1 {
          return "A month ago"
        } else {
          return "\(components.month!) months ago"
        }
      } else if components.weekOfYear ?? 0 > 0 {
        if components.weekOfYear == 1 {
          return "A week ago"
        } else {
          return "\(components.weekOfYear!) weeks ago"
        }
      } else if components.day ?? 0 > 0 {
        if components.day == 1 {
          return "A day ago"
        } else {
          return "\(components.day!) days ago"
        }
      }
    }

    if calendar.isDateInTomorrow(self) {
      return "Tomorrow"
    } else if self > now {
      let components = calendar.dateComponents([.day, .weekOfYear, .month, .year], from: now, to: self)
      if components.year ?? 0 > 0 {
        if components.year == 1 {
          return "In a year"
        } else {
          return "In \(components.year!) years"
        }
      } else if components.month ?? 0 > 0 {
        if components.month == 1 {
          return "In a month"
        } else {
          return "In \(components.month!) months"
        }
      } else if components.weekOfYear ?? 0 > 0 {
        if components.weekOfYear == 1 {
          return "In a week"
        } else {
          return "In \(components.weekOfYear!) weeks"
        }
      } else if components.day ?? 0 > 0 {
        if components.day == 1 {
          return "In a day"
        } else {
          return "In \(components.day!) days"
        }
      }
    }

    return ""
  }
}
