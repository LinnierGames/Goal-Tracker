//
//  HabitViewModel.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 3/13/22.
//

import SwiftUI

@MainActor
class HabitViewModel: ObservableObject {
  @Published var isLoading = false
  @Published var alert: AlertContent?
  @Published var stagedFiles = [URL]()
  @Published var importedFiles = [URL]()
  
  private let healthKitService = HealthKitService()
  private let networking = Networking.shared
  private let ud = UserDefaults(suiteName: "group.com.linniergames.Habit-Tracker")!

  init() {
    self._isHealthKitGranted = .init(initialValue: healthKitService.isSleepGranted)

    ud.synchronize()
    importedFiles = ((ud.array(forKey: "STAGED_FILES") as! [String]?) ?? []).compactMap(URL.init)
  }

  func deleteImportedFile(at index: Int) {
    var importedFiles = importedFiles
    importedFiles.remove(at: index)
    ud.set(importedFiles.map { $0.absoluteString }, forKey: "STAGED_FILES")
    self.importedFiles = importedFiles
  }

  func export(to host: String) {
    isLoading = true

    Task {
      var csvFiles = [CSVFile]()

      do {
        let request = FeelingSleepy.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        let context = PersistenceController.shared.container.viewContext
        let feelingSleepy = try! context.fetch(request)
        if !feelingSleepy.isEmpty {
          csvFiles.append(
            CSVFile(
              data: feelingSleepy,
              headers: "timestamp,activity",
              filename: "Feeling Sleepy.csv",
              csvRowFactory: { line in
                "\(line.timestamp),\(line.activity)"
              }
            )
          )
        }
      }

      do {
        let request = ShowerTimestamp.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        let context = PersistenceController.shared.container.viewContext
        let showerTimestamps = try! context.fetch(request)
        if !showerTimestamps.isEmpty {
          csvFiles.append(
            CSVFile(
              data: showerTimestamps,
              headers: "timestamp,products",
              filename: "Showers.csv",
              csvRowFactory: { line in
                "\(line.timestamp!),\(line.products!.joined(separator: ","))"
              }
            )
          )
        }
      }

      if !inBedTimes.isEmpty {
        csvFiles.append(
          CSVFile(
            data: inBedTimes,
            headers: "start time,end time,duration",
            filename: "Bedtimes.csv",
            csvRowFactory: { line in
              "\(line.start.stringValue),\(line.end.stringValue),\(line.duration)\n"
            }
          )
        )
      }

      do {
        try await networking.uploadData(
          csvFiles: csvFiles,
          csvFileURLs: stagedURLs + importedFiles,
          to: host
        )
        alert = AlertContent(title: "Upload Successful!")

        ud.set(nil, forKey: "STAGED_FILES")
        importedFiles = []
      } catch {
        alert = AlertContent(title: "Something Went Wrong", message: error.localizedDescription)
      }

      isLoading = false
    }
  }

  // MARK: Files

  @Published var stagedURLs = [URL]()

  func stageFiles(urls: [URL]) {
    stagedURLs.append(contentsOf: urls)
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
