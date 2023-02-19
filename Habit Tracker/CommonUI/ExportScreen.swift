//
//  ExportScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 2/18/23.
//

import SwiftUI

struct ExportScreen: View {

  let trackers: [Tracker]
  let logs: [TrackerLog]

  @Environment(\.managedObjectContext)
  private var viewContext

  init(trackers: [Tracker]? = nil) {

    let viewContext = PersistenceController.shared.container.viewContext

    if let trackers {
      self.trackers = trackers
    } else {
      let allTrackers = Tracker.fetchRequest()
      self.trackers = (try? viewContext.fetch(allTrackers)) ?? []
    }

    let allLogs = TrackerLog.fetchRequest()
    allLogs.predicate = NSPredicate(format: "tracker in %@", self.trackers)
    allLogs.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerLog.timestamp!, ascending: false)]
    self.logs = (try? viewContext.fetch(allLogs)) ?? []
  }

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
