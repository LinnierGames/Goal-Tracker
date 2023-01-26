//
//  TimeInterval+Date.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/15/23.
//

import Foundation

extension TimeInterval {
  init(minutes: Int) {
    self = Double(minutes) * 60
  }

  init(hours: Int) {
    self.init(minutes: 60 * hours)
  }

  init(days: Int) {
    self.init(hours: 24 * days)
  }
}
