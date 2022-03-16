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

  func export() {
    let request = FeelingSleepy.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
    let context = PersistenceController.shared.container.viewContext
    let sleep = try! context.fetch(request)

    networking.uploadData(feelingSleepy: sleep, timesInBed: inBedTimes, csvFiles: stagedURLs)
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
    _Concurrency.Task {
      await healthKitService.requestAccess()
      isHealthKitGranted = healthKitService.isSleepGranted
    }
  }

  func fetchHealthKit() {
    _Concurrency.Task {
      let sleep = await healthKitService.sleepData()
      inBedTimes = sleep
    }
  }
}

import Moya

struct RemoteStoreAPI {
  enum Endpoint {
    case uploadData(csvFiles: [(data: Data, filename: String)], csvURLs: [URL])
    case listOfData
    case uploadReport
    case listOfReports
  }

  let baseURL: URL
  let endpoint: Endpoint
}

extension RemoteStoreAPI: TargetType {

  var path: String {
    switch endpoint {
    case .uploadData, .listOfData:
      return "data"
    case .uploadReport, .listOfReports:
      return "reports"
    }
  }

  var method: Moya.Method {
    switch endpoint {
    case .uploadData, .uploadReport:
      return .post
    case .listOfData, .listOfReports:
      return .get
    }
  }

  var task: Task {
    switch endpoint {
    case .uploadData(let csvFiles, let csvURLs):
      let multipartName = "data"
      let csvFileParts = csvFiles.map { data, filename in
        MultipartFormData(
          provider: .data(data),
          name: multipartName,
          fileName: filename,
          mimeType: "text/plain"
        )
      }
      let csvURLParts = csvURLs.map { url in
        MultipartFormData(
          provider: .file(url),
          name: multipartName,
          fileName: url.lastPathComponent,
          mimeType: "text/plain"
        )
      }
      let parts = csvFileParts + csvURLParts

      return .uploadMultipart(parts)
    case .uploadReport:
      return .requestPlain
    case .listOfData:
      return .requestPlain
    case .listOfReports:
      return .requestPlain
    }
  }

  var headers: [String : String]? {
    return [
      "key": "635452ba20a7780588a9367a21f971cfd7a",
    ]
  }


}


func multipart() {
//  POST / HTTP/1.1
//  Content-Type: multipart/form-data; charset=utf-8; boundary=__X_PAW_BOUNDARY__
//  Host: echo.paw.cloud
//  Connection: close
//  User-Agent: Paw/3.3.1 (Macintosh; OS X/12.0.1) GCDHTTPRequest
//  Content-Length: 1266
//
//  --__X_PAW_BOUNDARY__
//  Content-Disposition: form-data; name="sleep"; filename="Sleep.csv"
//  Content-Type: text/csv
//
//  start date,end date,duration
//  2022-02-26 01:31:40,2022-02-26 09:11:07,27567.01620399952
//  2022-02-24 23:34:16,2022-02-25 07:44:58,29442.74739098549
//  2022-02-23 22:35:59,2022-02-24 08:44:44,36524.91954898834
//  2022-02-23 00:39:16,2022-02-23 08:49:07,29391.622969031334
//  2022-02-21 23:20:02,2022-02-22 08:26:49,32807.298303961754
//  2022-02-21 00:21:56,2022-02-21 08:28:01,29165.836801052094
//  2022-02-20 00:32:15,2022-02-20 10:46:05,36830.10278189182
//
//  --__X_PAW_BOUNDARY__
//  Content-Disposition: form-data; name="calory"; filename="CaloryWeightLog.csv"
//  Content-Type: text/csv
//
//  Date, Weight (lbs)
//  2021-05-31, 164.24
//  2021-05-31, 164.24
//  2021-05-31, 162.92
//  2021-05-31, 164.24
//  2021-05-31, 162.92
//  2021-05-31, 162.9
//  2021-06-07, 160.28
//  2021-06-14, 162.26
//  2021-06-21, 159.39
//  2021-06-28, 161.16
//  2021-07-05, 161.16
//  2021-07-14, 163.58
//  2021-07-20, 160.72
//  2021-07-27, 164.24
//  2021-08-09, 164.24
//  2021-08-17, 164.24
//  2021-08-23, 162.7
//  2021-10-16, 160.06
//  2021-10-16, 162.7
//  2022-01-23, 162.04
//  2022-01-23, 166.45
//  2022-01-23, 165.35
//  2022-01-23, 163.58
//  2022-01-23, 168.87
//  2022-01-23, 166.01
//  2022-01-23, 167.33
//  2022-01-23, 167.33
//
//  --__X_PAW_BOUNDARY__--
//
//

}
