//
//  SyncManager.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 2/20/23.
//

import SwiftUI

protocol SyncableSource {
  func syncDateRange(tracker: Tracker, range: ClosedRange<Date>) async
}

// start sync, request 30 days from today from all sync sources
// request at any time for data given a range and source
class ExternalSyncManager {
  private var sources = [SyncableSource]()
  private let persistanceController = PersistenceController.shared

  @discardableResult
  func attach(source: SyncableSource) -> Self {
    sources.append(source)
    return self
  }

  func sync() -> Self {
    let trackersWithExternalSources = Tracker.fetchRequest()
    trackersWithExternalSources.predicate = NSPredicate(
      format: "%K != nil", #keyPath(Tracker.externalDataSource)
    )
    let results = try! persistanceController.container.viewContext.fetch(trackersWithExternalSources)

    let today = Date()
    let last30Days = today.addingTimeInterval(.init(days: -30))
    for tracker in results {
      syncDateRange(tracker: tracker, range: last30Days...today)
    }

    return self
  }

  func syncDateRange(tracker: Tracker, range: ClosedRange<Date>) {
    Task {
      for source in sources {
        await source.syncDateRange(tracker: tracker, range: range)
      }
    }
  }
}

extension ExternalSyncManager: ObservableObject {}
