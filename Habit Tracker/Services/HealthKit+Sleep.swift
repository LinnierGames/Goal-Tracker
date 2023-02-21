//
//  HealthKit+Sleep.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 2/18/23.
//

import Foundation
import HealthKit

struct SleepSample {
  let id: UUID
  let start: Date
  let end: Date
  let duration: TimeInterval
}

extension HealthKitService {
  var isSleepGranted: Bool {
    store.authorizationStatus(
      for: .categoryType(forIdentifier: .sleepAnalysis)!
    ) == .sharingAuthorized
  }

  func sleepData(date: ClosedRange<Date>) async throws -> [SleepSample] {
    guard isHealthDataAvailable && isSleepGranted else { return [] }

    guard
      let sleepType = HKObjectType.categoryType(
        forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis
      ) else {
        fatalError()
      }

//    let thisDevice = HKDevice.local().localIdentifier!
//    let devicePredicate = HKQuery.predicateForObjects(withDeviceProperty: HKDevicePropertyKeyLocalIdentifier, allowedValues: [thisDevice])
    guard let eesiPhone = try await execute(sampleType: sleepType, samplePredicate: nil).first else {
      return []
    }

    return try await withCheckedThrowingContinuation { continuation in
      let inBedPredicate = HKQuery.predicateForCategorySamples(
        with: .equalTo, value: HKCategoryValueSleepAnalysis.inBed.rawValue
      )
      let datePredicate = HKQuery.predicateForSamples(withStart: date.lowerBound, end: date.upperBound)
      let devicePedicate = HKSourceQuery.predicateForObjects(from: eesiPhone)
      let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [devicePedicate, inBedPredicate, datePredicate])
      let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

      // TODO: migrate to async/await
      let query = HKSampleQuery(
        sampleType: sleepType,
        predicate: predicate,
        limit: HKObjectQueryNoLimit,
        sortDescriptors: [sortDescriptor]
      ) { query, result, error in
        if let error {
          continuation.resume(throwing: error)
          return
        }

        guard let result = result as? [HKCategorySample] else { fatalError() }

        let keyFormatter = DateFormatter()
        keyFormatter.dateFormat = "MM/dd/yyyy"
        let inBedTimes = result.map { (sample: HKCategorySample) in
          let id = sample.uuid
          let startDate = sample.startDate
          let endDate = sample.endDate
          let sleepTimeForOneDay = sample.endDate.timeIntervalSince(sample.startDate)
          return SleepSample(id: id, start: startDate, end: endDate, duration: sleepTimeForOneDay)
        }.reduce(into: [String: SleepSample]()) { (partialResult, sample: SleepSample) in
          let key = keyFormatter.string(from: sample.start)

          if let maxSample = partialResult[key], sample.duration > maxSample.duration {
            partialResult[key] = sample
          } else {
            partialResult[key] = sample
          }
        }.values.sorted { $0.start < $1.start }

        continuation.resume(with: .success(inBedTimes))
      }

      self.store.execute(query)
    }
  }

  func execute(sampleType: HKSampleType, samplePredicate: NSPredicate?) async throws -> Set<HKSource> {
    try await withCheckedThrowingContinuation { continuation in
      let query = HKSourceQuery(sampleType: sampleType, samplePredicate: nil) { q, s, e in
        if let e {
          return continuation.resume(throwing: e)
        }

        guard let result = s else { fatalError() }

        let filter = result.filter({ s in
          s.bundleIdentifier == "com.apple.health.11AD51FE-9D7E-4736-8831-FD7FFCABFFA4" // EES iPhone
        })

        continuation.resume(returning: filter)
      }

      self.store.execute(query)
    }
  }
}
