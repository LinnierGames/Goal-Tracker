//
//  tracker.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 2/9/23.
//

import CoreData
import SwiftUI

/// List builder for fields with existing values
struct TrackerLogFieldValuesList<Content: View>: View {
  @ObservedObject var tracker: Tracker
  @ObservedObject var log: TrackerLog

  enum TrackerLogFieldValue {
    case string(String)
    case integer(Int)
    case boolean(Bool)
    case double(Double)

    var stringValue: String {
      switch self {
      case .string(let value):
        return value
      case .integer(let value):
        return String(value)
      case .double(let value):
        return String(value)
      case .boolean(let value):
        return value ? "True" : "False"
      }
    }

    var boolValue: Bool {
      switch self {
      case .string, .integer, .double:
        return false
      case .boolean(let value):
        return value
      }
    }
  }

  private let content: (TrackerLogField, TrackerLogFieldValue) -> Content

  @FetchRequest
  private var fields: FetchedResults<TrackerLogField>

  @Environment(\.managedObjectContext)
  private var viewContext

  init(
    tracker: Tracker, log: TrackerLog,
    @ViewBuilder content: @escaping (TrackerLogField, TrackerLogFieldValue) -> Content
  ) {
    self.content = content
    self.tracker = tracker
    self.log = log
    self._fields = FetchRequest(
      sortDescriptors: [SortDescriptor(\TrackerLogField.title)],
      predicate: NSPredicate(format: "tracker = %@", tracker)
    )
  }

  var fieldValues: [(field: TrackerLogField, value: TrackerLogFieldValue)] {
    fields.compactMap { field in
      let fetchValueForFieldInLog = TrackerLogValue.fetchRequest()
      fetchValueForFieldInLog.predicate =
        NSPredicate(format: "log = %@ AND field = %@", log, field)
      let results = try! viewContext.fetch(fetchValueForFieldInLog)

      if results.count > 1 {
        fatalError("Should only have one values per field per log")
      } else if let value = results.first {
        switch (field.type, value.stringValue, value.integerValue, value.boolValue, value.doubleValue) {
        case (.string, let string?, _, _, _):
          return (field, .string(string))
        case (.integer, _, let integer, _, _):
          return (field, .integer(Int(integer)))
        case (.boolean, _, _, let bool, _):
          return (field, .boolean(bool))
        case (.double, _, _, _, let double):
          return (field, .double(double))
        default:
          return nil
        }
      } else {
        return nil
      }
    }
  }

  var body: some View {
    if fields.isEmpty {
      EmptyView()
    } else {
      VStack {
        ForEach(fieldValues, id: \.field) { field, value in
          content(field, value)
        }
      }
    }
  }
}
