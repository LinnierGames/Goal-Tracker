//
//  TrackerLog+HealthKit.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 2/20/23.
//

import CoreData

enum TrackerHealthKitLog: CaseIterable {
  case sleepInBedIntervals
//
//  var titleForNewTracker: String {
//    switch self {
//    case .sleepInBedIntervals:
//      return "In Bed Intervals for Sleep"
//    }
//  }

//  // E.g. health-kit:sleep-in-bed-interval
//  var stringValue: String {
//    switch self {
//    case .sleepInBedIntervals:
//      return "health-kit:sleep-in-bed-intervals"
//    }
//  }

//  var source: String {
//    switch self {
//    case .sleepInBedIntervals:
//      return "health-kit"
//    }
//  }
}

extension TrackerLog {
  
  // MARK: - Sleep

  static func makeHealthKitInBedLog(
    sample: SleepSample,
    sleepTracker: Tracker,
    context: NSManagedObjectContext
  ) -> TrackerLog {
    let new = TrackerLog(context: context)
    new.externalDataSourceID = sample.id.uuidString
    new.timestamp = sample.start
    new.endDate = sample.end

    // TODO: add values to fields

    sleepTracker.addToLogs(new)

    return new
  }

  // MARK: - Other HealthKit Data Sources

//  var externalHealthDataSource: TrackerHealthKitLog? {
//    switch externalDataSource {
//    case TrackerHealthKitDataSource.sleepInBedIntervals.stringValue:
//      return .sleepInBedIntervals
//    default:
//      return nil
//    }
//  }
}
