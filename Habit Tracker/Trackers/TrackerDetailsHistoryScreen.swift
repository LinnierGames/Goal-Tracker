//
//  TrackerDetailsHistoryScreen.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/15/23.
//

import CoreData
import SwiftUI

struct TrackerDetailsHistoryScreen: View {
  @ObservedObject var tracker: Tracker

  @FetchRequest
  private var entries: FetchedResults<TrackerLog>

  @Environment(\.managedObjectContext)
  private var viewContext

  init(_ tracker: Tracker) {
    self.tracker = tracker
    self._entries = FetchRequest(
      sortDescriptors: [SortDescriptor(\TrackerLog.timestamp, order: .reverse)],
      predicate: NSPredicate(format: "tracker = %@", tracker)
    )
  }

  var body: some View {
    NavigationView {
      List {
        ForEach(entries) { log in
          NavigationLink {
            TrackerEntryDetailScreen(tracker: tracker, log: log)
          } label: {
            VStack(alignment: .leading) {
              Text("\(log.timestamp!, style: .date) at \(log.timestamp!, style: .time)")

              TrackerLogFieldValuesList(tracker: tracker, log: log) { field, value in
                HStack {
                  Text(field.title!)
                  Spacer()
                  switch value {
                  case .string(let string):
                    Text(string)
                  case .integer(let int):
                    Text(int, format: .number)
                  case .double(let double):
                    Text(double, format: .number)
                  case .boolean(let bool):
                    Text(bool ? "True" : "False")
                  }
                }
                .font(.caption2)
              }
            }
          }
        }
        .onDelete(perform: deleteEntry)
      }
      .navigationBarTitleDisplayMode(.large)
      .navigationTitle(tracker.title!)

      .toolbar {
        Button {
          withAnimation {
            let newLog = TrackerLog(context: viewContext)
            newLog.timestamp = Date()
            tracker.addToLogs(newLog)

            try! viewContext.save()
          }
        } label: {
          Image(systemName: "plus")
        }
      }
    }
  }

  private func deleteEntry(indexes: IndexSet) {
    withAnimation {
      viewContext.delete(entries[indexes.first!])
      try! viewContext.save()
    }
  }
}
