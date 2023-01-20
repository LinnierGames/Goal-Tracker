//
//  Tracker.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/17/23.
//

import Foundation

extension Habit {
  var mostRecentEntry: HabitEntry? {
    allEntries
      .sorted { $0.timestamp! > $1.timestamp! }
      .first
  }

  var allEntries: [HabitEntry] {
    entries?.allManagedObjects() ?? []
  }
}
