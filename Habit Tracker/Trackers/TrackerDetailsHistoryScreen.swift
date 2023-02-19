//
//  TrackerDetailsHistoryScreen.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/15/23.
//

import CoreData
import SwiftUI

extension TrackerLog {
}

struct TrackerDetailsHistoryScreen: View {
  @ObservedObject var tracker: Tracker

  @SectionedFetchRequest
  private var logs: SectionedFetchResults<String, TrackerLog>

  @Environment(\.managedObjectContext)
  private var viewContext

  init(_ tracker: Tracker) {
    self.tracker = tracker
    self._logs = SectionedFetchRequest(
      sectionIdentifier: \.timestampWeek,
      sortDescriptors: [SortDescriptor(\.timestamp, order: .reverse)],
      predicate: NSPredicate(format: "tracker = %@", tracker)
    )
  }

  var body: some View {
    NavigationView {
      List {
        ForEach(logs) { section in
          Section(section.id) {
            ForEach(section) { log in
              NavigationLink {
                TrackerEntryDetailScreen(tracker: tracker, log: log)
              } label: {
                VStack(alignment: .leading) {
                  Text(log.timestampFormat)

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
            .onDelete { index in
              withAnimation {
                viewContext.delete(section[index.first!])
                try! viewContext.save()
              }
            }
          }
        }
      }
      .navigationBarTitleDisplayMode(.large)
      .navigationTitle(tracker.title!)

      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          SheetLink {
            ExportScreen(trackers: [tracker])
          } label: {
            Image(systemName: "square.and.arrow.up")
          }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
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
  }
}
