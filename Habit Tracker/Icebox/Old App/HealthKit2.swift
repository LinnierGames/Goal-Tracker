//
//  HealthKit.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 3/13/22.
//

import UIKit
import HealthKit

struct SleepSample {
  let start: Date
  let end: Date
  let duration: TimeInterval
}

class HealthKitService2 {
  let healthStore = HKHealthStore()

  var isHealthDataAvailable: Bool {
    HKHealthStore.isHealthDataAvailable()
  }

  var isSleepGranted: Bool {
    healthStore.authorizationStatus(
      for: .categoryType(forIdentifier: .sleepAnalysis)!
    ) == .sharingAuthorized
  }

  func requestAccess(completion: @escaping () -> Void) {
    guard isHealthDataAvailable else { return }

    let allTypes = Set([
//      HKObjectType.workoutType(),
//      HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
//      HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
//      HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
//      HKObjectType.quantityType(forIdentifier: .heartRate)!,
//      HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.mindfulSession)!,
      HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
    ])

    healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
      if !success {
        // Handle the error here.
        print("no good", error!)
        return
      }

      print("requestAuthorization good!")
      completion()
    }
  }

  func requestAccess() async {
    await withCheckedContinuation { continuation in
      requestAccess {
        continuation.resume()
      }
    }
  }

  func sleepData() async -> [SleepSample] {
    guard isHealthDataAvailable && isSleepGranted else { return [] }
    return await readSleep(store: healthStore)
  }

  private func readSleep(store: HKHealthStore) async -> [SleepSample] {
    guard
      let sleepType = HKObjectType.categoryType(
        forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis
      ) else {
        fatalError()
      }

    return await withCheckedContinuation { continuation in
      let query = HKSourceQuery(sampleType: sleepType, samplePredicate: nil) { _, sources, _ in
        guard let sources = sources, let pillowSource = sources.first(where: { $0.name == "Pillow" }) else {
          fatalError()
        }

        let inBedPredicate = HKQuery.predicateForCategorySamples(
          with: .equalTo, value: HKCategoryValueSleepAnalysis.inBed.rawValue
        )
        let pillowSourcePredicate = HKSourceQuery.predicateForObjects(from: pillowSource)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [inBedPredicate, pillowSourcePredicate])
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        // the block completion to execute
        let query = HKSampleQuery(
          sampleType: sleepType,
          predicate: predicate,
          limit: 7,
          sortDescriptors: [sortDescriptor]
        ) { query, tmpResult, error in
          if error != nil {
            fatalError()
          }

          guard let result = tmpResult as? [HKCategorySample] else { fatalError() }

          let inBedTimes = result
            .map { inBedSample -> SleepSample in
              let startDate = inBedSample.startDate
              let endDate = inBedSample.endDate
              let sleepTimeForOneDay = inBedSample.endDate.timeIntervalSince(inBedSample.startDate)
              return SleepSample(start: startDate, end: endDate, duration: sleepTimeForOneDay)
            }

//          DispatchQueue.main.async {
//            self.shareSheet(data: inBedTimes)
//          }
          continuation.resume(with: .success(inBedTimes))
        }

        store.execute(query)
      }

      store.execute(query)
    }
  }
}

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.

  }

  func shareSheet(data: [SleepSample]) {

    var csv = "start date,end date,duration\n"
    for sample in data {
      csv += "\(sample.start.stringValue),\(sample.end.stringValue),\(sample.duration)\n"
    }
    guard let csvData = csv.data(using: .utf8) else { fatalError() }
    guard let csvFileURL = store(data: csvData, at: "Sleep.csv") else { fatalError() }

    let ac = UIActivityViewController(activityItems: [csvFileURL], applicationActivities: nil)
    present(ac, animated: true)
  }

  func store(data: Data, at filename: String) -> URL? {
    let fm = FileManager.default

    let cachesDirectory = fm.urls(for: .cachesDirectory, in: .userDomainMask).first!
    let destination = cachesDirectory.appendingPathComponent(filename)

    guard (try? data.write(to: destination)) != nil else { return nil }

    return destination
  }
}

class CSVAttachment: UIActivity {
  override var activityTitle: String? { "Sleep.csv" }
  override class var activityCategory: UIActivity.Category {
    .share
  }
}

extension Date {
  var stringValue: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter.string(from: self)
  }
}

