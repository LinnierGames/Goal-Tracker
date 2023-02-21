//
//  Trackers+HealthKit.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 2/20/23.
//

import CoreData

enum TrackerHealthKitDataSource: CaseIterable {
  case sleepInBedIntervals

  var titleForNewTracker: String {
    switch self {
    case .sleepInBedIntervals:
      return "In Bed Intervals for Sleep"
    }
  }

  // E.g. health-kit:sleep-in-bed-interval
  var stringValue: String {
    switch self {
    case .sleepInBedIntervals:
      return "health-kit:sleep-in-bed-intervals"
    }
  }

//  var source: String {
//    switch self {
//    case .sleepInBedIntervals:
//      return "health-kit"
//    }
//  }
}

extension Tracker {

  // MARK: - All HealthKit Sources

  static func makeHealthKitTracker(
    dataSource: TrackerHealthKitDataSource,
    context: NSManagedObjectContext
  ) -> Tracker {
    let new = Tracker(context: context)
    new.title = dataSource.titleForNewTracker
    new.externalDataSource = dataSource.stringValue

    // TODO: create fields and mark them as read-only

    return new
  }

  var externalHealthDataSource: TrackerHealthKitDataSource? {
    switch externalDataSource {
    case TrackerHealthKitDataSource.sleepInBedIntervals.stringValue:
      return .sleepInBedIntervals
    default:
      return nil
    }
  }
}
