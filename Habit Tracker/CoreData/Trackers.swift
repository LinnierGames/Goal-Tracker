//
//  Tracker.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/17/23.
//

import CoreData

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

  func encodeIntentIdentifier() -> String {
    "\(objectID.uriRepresentation().absoluteString) \(allFields.isEmpty ? "HAS_NO_FIELDS" : "HAS_FIELDS")"
  }

  static func decodeIntentIdentifier(
    _ identifer: String,
    coordinator: NSPersistentStoreCoordinator
  ) -> (objectID: NSManagedObjectID, hasFields: Bool)? {
    let components = identifer.split(separator: " ")
    guard components.count == 2, let objectURL = URL(string: String(components[0])) else {
      assertionFailure("Decoding failed")
      return nil
    }

    guard let managedObjectID = coordinator.managedObjectID(forURIRepresentation: objectURL) else {
      assertionFailure("Decoding failed: invalid managed object ID")
      return nil
    }

    let hasFields: Bool
    switch components[1] {
    case "HAS_NO_FIELDS":
      hasFields = false
    case "HAS_FIELDS":
      hasFields = true
    default:
      assertionFailure("Decoding failed: invalid component")
      return nil
    }

    return (managedObjectID, hasFields)
  }
}

extension TrackerLog {
  var allValues: [TrackerLogValue] {
    values?.allManagedObjects() ?? []
  }

  @objc var timestampFormat: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, d 'at' HH:mm"
    return formatter.string(from: timestamp!)
  }

  @objc var timestampWeek: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM yyyy, 'week' F"
    return formatter.string(from: timestamp!)
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

  func encodeIntentIdentifier() -> String {
    "\(objectID.uriRepresentation().absoluteString) \(type.description)"
  }

  static func decodeIntentIdentifier(
    _ identifer: String,
    coordinator: NSPersistentStoreCoordinator
  ) -> (objectID: NSManagedObjectID, fieldType: TrackerLogFieldType)? {
    let components = identifer.split(separator: " ")
    guard components.count == 2, let objectURL = URL(string: String(components[0])) else {
      assertionFailure("Decoding failed")
      return nil
    }

    guard let managedObjectID = coordinator.managedObjectID(forURIRepresentation: objectURL) else {
      assertionFailure("Decoding failed: invalid managed object ID")
      return nil
    }

    let fieldType: TrackerLogFieldType
    switch components[1] {
    case TrackerLogFieldType.string.description:
      fieldType = .string
    case TrackerLogFieldType.integer.description:
      fieldType = .integer
    case TrackerLogFieldType.double.description:
      fieldType = .double
    case TrackerLogFieldType.boolean.description:
      fieldType = .boolean
    default:
      assertionFailure("Decoding failed: invalid field type")
      return nil
    }

    return (managedObjectID, fieldType)
  }
}

extension TrackerLogValue {
  var string: String {
    switch field!.type {
    case .string:
      return stringValue ?? ""
    case .integer:
      return String(integerValue)
    case .double:
      return String(doubleValue)
    case .boolean:
      return boolValue ? "True" : "False"
    }
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
