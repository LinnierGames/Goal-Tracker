//
//  TrackerLog+SwiftUI.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 4/28/24.
//

import CoreData
import SwiftUI

extension View {
  func addLogContextMenu(
    viewContext: NSManagedObjectContext,
    tracker: Tracker
  ) -> some View {
    addLogContextMenu(viewContext: viewContext, trackers: [tracker])
  }

  func addLogContextMenu(
    viewContext: NSManagedObjectContext,
    trackers: [Tracker]
  ) -> some View {
    contextMenu {
      ForEach(trackers) { tracker in
        Button(
          action: {
            addLog(tracker: tracker, viewContext: viewContext)
          },
          title: "Add Log to \(tracker.title ?? "")",
          systemImage: "plus"
        )
      }
    }
  }

  private func addLog(tracker: Tracker, viewContext: NSManagedObjectContext) {
    let newLog = TrackerLog(context: viewContext)
    newLog.timestamp = Date()
    tracker.addToLogs(newLog)

    try! viewContext.save()
  }
}
