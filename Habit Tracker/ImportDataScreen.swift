//
//  ImportDataScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/15/23.
//

import CoreData
import SwiftUI

struct ImportDataScreen: View {
  @State private var stagedURLs = [URL]()
  @Environment(\.managedObjectContext) var viewContext

  var body: some View {
    VStack {
      List {
        Section("Habits") {
          FilePicker(types: [.commaSeparatedText], allowMultiple: false) { urls in
            stageFiles(urls: urls)
          } label: {
            HStack {
              Image(systemName: "doc.on.doc")
              Text("Pick File")
            }
          }
          if !stagedURLs.isEmpty {
            ForEach(stagedURLs, id: \.self) { url in
              Text(url.lastPathComponent)
            }
            .onDelete { index in
              stagedURLs.remove(at: index.first!)
            }
          }
        }

        Section("Sleep") {

        }

        Section("Blocks") {

        }

        Section("Calory") {

        }
      }

      ButtonFill("Import", fill: .blue) {
        importHabits(url: stagedURLs[0])
      }
      .disabled(stagedURLs.isEmpty)
    }
  }

  private func stageFiles(urls: [URL]) {
    stagedURLs = urls
  }

  private func importHabits(url: URL) {
    guard
      let data = try? Data(contentsOf: url),
      let content = String(data: data, encoding: .utf8)
    else {
      return
    }

    struct CSV {
      let headers: [String]

      struct Row {
        let columns: [String]
      }
      let rows: [Row]
    }

    func findItOrCreateIt<T: NSManagedObject>(
      fetch: NSFetchRequest<T>,
      predicate: () -> NSPredicate,
      createIt: () -> T
    ) -> T {
      do {
        fetch.predicate = predicate()
        let result = try viewContext.fetch(fetch)

        if let it = result.first {
          return it
        } else {
          return createIt()
        }
      } catch {
        assertionFailure(error.localizedDescription)

        return createIt()
      }
    }

    func findHabitOrCreateIt(title: String) -> Habit {
      findItOrCreateIt(fetch: Habit.fetchRequest()) {
        NSPredicate(format: "title = %@", title)
      } createIt: {
        let new = Habit(context: viewContext)
        new.title = title
        return new
      }
    }

    func findTimestampOrCreateIt(date: Date, habitTitle: String) -> HabitEntry {
      findItOrCreateIt(fetch: HabitEntry.fetchRequest()) {
        NSPredicate(format: "timestamp = %@ AND habit.title = %@", date as NSDate, habitTitle)
      } createIt: {
        let new = HabitEntry(context: viewContext)
        new.timestamp = date
        return new
      }
    }

    let stringRows = content.components(
      separatedBy: "\n"
    )
    let rows = Array(
      stringRows.map { CSV.Row(columns: $0.components(separatedBy: ",")) }.dropFirst()
    )
    let headers = stringRows[0].split(separator: ",").map(String.init)

    let csv = CSV(headers: headers, rows: rows)

    guard
      let trackerIndex = csv.headers.firstIndex(of: "Tracker"),
      let timestampIndex = csv.headers.firstIndex(of: "Date (ISO 8601)")
    else {
      fatalError()
    }

    for row in csv.rows {
      guard
        row.columns.indices.contains(trackerIndex),
        row.columns.indices.contains(timestampIndex)
      else {
        continue
      }

      let tracker = row.columns[trackerIndex]
      let timestampString = row.columns[timestampIndex]

      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
      let timestamp = formatter.date(from: timestampString)!

      let habit = findHabitOrCreateIt(title: tracker)
      let entry = findTimestampOrCreateIt(date: timestamp, habitTitle: tracker)

      habit.addToEntries(entry)
    }

    try! viewContext.save()
  }
}
