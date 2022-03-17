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
  let networking = Networking.shared

  init() {
    self._isHealthKitGranted = .init(initialValue: healthKitService.isSleepGranted)
  }

  func export(to host: String) {
    let request = FeelingSleepy.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
    let context = PersistenceController.shared.container.viewContext
    let feelingSleepy = try! context.fetch(request)

    let csvFiles = [
      CSVFile(
        data: feelingSleepy,
        headers: "timestamp,activity",
        filename: "Feeling Sleepy.csv",
        csvRowFactory: { line in
          "\(line.timestamp),\(line.activity)"
        }
      ),

      CSVFile(
        data: inBedTimes,
        headers: "start time,end time,duration",
        filename: "Bedtimes.csv",
        csvRowFactory: { line in
          "\(line.start.stringValue),\(line.end.stringValue),\(line.duration)\n"
        }
      ),
    ]

    networking.uploadData(csvFiles: csvFiles, csvFileURLs: stagedURLs, to: host)
  }

  // MARK: Files

  @Published var stagedURLs = [URL]()

  func stageFiles(urls: [URL]) {
    stagedURLs = urls
  }

  // MARK: Health Kit

  @Published var inBedTimes = [SleepSample]()
  @Published var isHealthKitGranted: Bool

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
}
