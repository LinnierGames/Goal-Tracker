//
//  ExportScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 2/18/23.
//

import SwiftUI

struct ExportScreen: View {

//  let logFetchRequest: NSFetchRequest<TrackerLog>

  @Environment(\.managedObjectContext)
  private var viewContext

//  static func allLogs() -> ExportScreen {
//    let allLogs = TrackerLog.fetchRequest()
//    allLogs.sortDescriptors = []
//
//
//    return ExportScreen(logFetchRequest: <#T##NSFetchRequest<TrackerLog>#>, fields: <#T##[String]#>)
//  }

  @State private var data: URL?

  var body: some View {
    NavigationView {
      Button("Share!") {
        self.data = export()
      }
    }.sheet(item: $data) { data in
      ShareSheet(activityItems: [data])
    }
  }

  private func export() -> URL {
    let allLogs = TrackerLog.fetchRequest()
    allLogs.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerLog.timestamp!, ascending: false)]
    let logs = (try? viewContext.fetch(allLogs)) ?? []

    let allTrackers = Tracker.fetchRequest()
    let trackers = (try? viewContext.fetch(allTrackers)) ?? []

    let fields = trackers.flatMap { tracker in
      tracker.allFields.map { field in
        "\(tracker.title!.abreviated).\(field.title!)"
      }
    }
    let headers = ["Date ISO", "Tracker", "Notes"] + fields

    let rows = logs.map { log in
      let dateISO = ISO8601DateFormatter().string(from: log.timestamp!)
      let tracker = log.tracker!.title!
      let notes = log.notes ?? ""

      var row = [dateISO, tracker, notes] + Array(repeating: "", count: fields.count)

      for fieldValue in log.allValues {
        let field = fieldValue.field!.title!
        let value = fieldValue.string

        guard let headerIndex = headers.firstIndex(where: { $0.hasSuffix(field) }) else {
          continue
        }

        row[headerIndex] = value
      }

      return row.doubleQuoted.joined(separator: ",")
    }.joined(separator: "\n")

    let csvString = "\(headers.doubleQuoted.joined(separator: ","))\n\(rows)"
    let csvData = csvString.data(using: .utf8)!

    let name = "Trackers.csv"
    let csvURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent(name)
    try! csvData.write(to: csvURL)
    return csvURL
  }
}

extension URL: Identifiable {
  public var id: String { absoluteString }
}

extension String {
  var abreviated: String {
    split(separator: " ")
      .compactMap { $0.first.flatMap { String($0)} }
      .map(\.localizedUppercase)
//      .filter { $0.unicodeScalars.allSatisfy { CharacterSet.capitalizedLetters.contains($0) } }
      .joined()
  }
}

extension Array<String> {
  var doubleQuoted: [String] {
    map { "\"\($0)\"" }
  }
}
