//
//  HabitViewModel.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 3/13/22.
//

import SwiftUI

@MainActor
class HabitViewModel: ObservableObject {
  let healthKitService = HealthKitService()

  @Published var inBedTimes = [SleepSample]()
  @Published var isHealthKitGranted: Bool

  init() {
    self._isHealthKitGranted = .init(initialValue: healthKitService.isSleepGranted)
  }

  func requestHealthKitPremission() {
    Task {
      await healthKitService.requestAccess()
      isHealthKitGranted = healthKitService.isSleepGranted
    }
  }

  func fetchHealthKit() {
    Task {
      let sleep = await healthKitService.sleepData()
      inBedTimes = sleep
    }
  }

  func makeCSV() {

    // Sleep
//      var csv = "start date,end date,duration\n"
//      for sample in inBedTimes {
//        csv += "\(sample.start.stringValue),\(sample.end.stringValue),\(sample.duration)\n"
//      }
//      guard let csvData = csv.data(using: .utf8) else { fatalError() }
//      guard let csvFileURL = store(data: csvData, at: "Sleep.csv") else { fatalError() }
  }
}
