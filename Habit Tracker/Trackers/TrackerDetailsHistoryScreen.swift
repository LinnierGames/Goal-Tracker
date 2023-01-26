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
        ForEach(entries) { entry in
          NavigationLink {
            TrackerEntryDetailScreen(tracker: tracker, entry: entry)
          } label: {
            Text("\(entry.timestamp!, style: .date) at \(entry.timestamp!, style: .time)")
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
