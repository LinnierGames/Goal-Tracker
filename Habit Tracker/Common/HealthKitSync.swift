//
//  HealthKitSync.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 2/20/23.
//

import CoreData
import SwiftUI

class HealthKitSync: SyncableSource {
  let healthKitService = HealthKitService.shared
  let persistenceController = PersistenceController.shared

  func syncDateRange(tracker: Tracker, range: ClosedRange<Date>) async {
    guard let source = tracker.externalHealthDataSource else {
      return
    }

    do {
      switch source {
      case .sleepInBedIntervals:
        let results = try await healthKitService.sleepData(date: range)

        for sample in results {
          await MainActor.run {
            _ = findLogOrCreateIt(
              sample: sample,
              tracker: tracker,
              context: persistenceController.container.viewContext
            )
          }
        }
      }

    } catch {
      fatalError(error.localizedDescription)
    }
  }

  private func findLogOrCreateIt(
    sample: SleepSample,
    tracker: Tracker,
    context: NSManagedObjectContext
  ) -> TrackerLog {
    let logBySampleUUID = TrackerLog.fetchRequest()
    logBySampleUUID.predicate = NSPredicate(
      format: "%K == %@",
      #keyPath(TrackerLog.externalDataSourceID), sample.id.uuidString
    )

    let results = try! context.fetch(logBySampleUUID)

    if let first = results.first {
      print("sample found")
      return first
    } else {
      print("sample not found. create new one")
      let new = TrackerLog.makeHealthKitInBedLog(
        sample: sample,
        sleepTracker: tracker,
        context: context
      )
      try! context.save()

      return new
    }
  }
}
