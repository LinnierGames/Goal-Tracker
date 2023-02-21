//
//  HabbitsScreen.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/14/23.
//

import SwiftUI

struct TrackersScreen: View {
  @State private var newTrackerTitle = ""

  @Environment(\.managedObjectContext)
  private var viewContext

  @FetchRequest(sortDescriptors: [SortDescriptor(\Tracker.title)])
  private var trackers: FetchedResults<Tracker>
  @State private var query = ""

  var body: some View {
    NavigationView {
      List(trackers) { tracker in
        NavigationSheetLink {
          TrackerDetailScreen(tracker)
        } label: {
          Text(tracker.title ?? "Untitled")
            .foregroundColor(.primary)
            .contextMenu {
              Button(action: { addLog(for: tracker) }, title: "Add log", systemImage: "plus")
            }
        }
      }
      .navigationTitle("Trackers")

      .searchable(text: $query)
      .onChange(of: query) { newValue in
        trackers.nsPredicate = query.isEmpty ? nil : NSPredicate(
          format: "%K CONTAINS[cd] %@", #keyPath(Tracker.title), query
        )
      }

      .toolbar {
        ToolbarItemGroup(placement: .navigationBarLeading) {
          SheetLink {
            ImportScreen()
          } label: {
            Image(systemName: "square.and.arrow.down")
          }
          SheetLink {
            ExportScreen()
          } label: {
            Image(systemName: "square.and.arrow.up")
          }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          AlertLink(title: "Add Tracker") {
            TextField("Title", text: $newTrackerTitle)
            Button("Cancel", role: .cancel, action: {})
            Button("Add", action: addNewTracker)
          } message: {
            Text("enter the title for your new tracker")
          } label: {
            Image(systemName: "plus")
          }
        }
      }
    }
  }

  private func addNewTracker() {
    let newTracker = Tracker(context: viewContext)
    newTracker.title = newTrackerTitle
    try! viewContext.save()

    newTrackerTitle = ""
  }

  private func addLog(for tracker: Tracker) {
    let newLog = TrackerLog(context: viewContext)
    newLog.timestamp = Date()
    tracker.addToLogs(newLog)

    try! viewContext.save()
  }
}
