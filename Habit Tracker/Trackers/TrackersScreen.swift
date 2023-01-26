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
  private var items: FetchedResults<Tracker>

  var body: some View {
    NavigationView {
      List(items) { tracker in
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
      .toolbar {
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
