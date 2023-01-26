//
//  Tracker.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/17/23.
//

import Foundation

extension Tracker {
  var mostRecentLog: TrackerLog? {
    allLogs
      .sorted { $0.timestamp! > $1.timestamp! }
      .first
  }

  var allLogs: [TrackerLog] {
    logs?.allManagedObjects() ?? []
  }
}

//Tracker
//+ fields
//++ title
//++ type
//++ logValues
//
//TrackerLog
//+ tracker
//+ fieldValues
//++ field
//++ intValue/stringValue/boolValue/floatValue
