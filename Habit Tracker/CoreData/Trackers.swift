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

  var allFields: [TrackerLogField] {
    fields?.allManagedObjects() ?? []
  }
}

extension TrackerLog {
  var allValues: [TrackerLogValue] {
    values?.allManagedObjects() ?? []
  }
}

enum TrackerLogFieldType: Int16, CaseIterable, Identifiable {
  var id: Int16 { rawValue }

  case string, integer, boolean, double

  var description: String {
    switch self {
    case .string:
      return "String"
    case .integer:
      return "Integer"
    case .boolean:
      return "True/False"
    case .double:
      return "Decimal"
    }
  }
}

extension TrackerLogField {
  var type: TrackerLogFieldType {
    get {
      TrackerLogFieldType(rawValue: typeRawValue)!
    }
    set {
      typeRawValue = newValue.rawValue
    }
  }
}

extension TrackerLogValue {
//  static let integerNilValue = Int64.max
//  static let doubleDoubleValue = Double.greatestFiniteMagnitude
//
//  var string: INT? {
//    get {
//
//    }
//    set {
//
//    }
//  }
//
//  var integer: INT? {
//    get {
//
//    }
//    set {
//
//    }
//  }
//
//  var boolean: INT? {
//    get {
//
//    }
//    set {
//
//    }
//  }
//
//  var double: INT? {
//    get {
//
//    }
//    set {
//
//    }
//  }
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
