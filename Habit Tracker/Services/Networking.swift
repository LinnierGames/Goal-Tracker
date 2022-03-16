//
//  Networking.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 3/15/22.
//

import Foundation
import Moya

class Networking {
  static let shared = Networking()

  let api = MoyaProvider<RemoteStoreAPI>()

  func uploadData(feelingSleepy: [FeelingSleepy], timesInBed: [SleepSample], csvFiles: [URL]) {
    var csvFilesAndNames = [(data: Data, filename: String)]()
    let sleepCSV = makeCSV(
      headers: "timestamp,activity",
      data: feelingSleepy, line: { line in
        "\(line.timestamp),\(line.activity)"
      }
    )
    csvFilesAndNames.append((data: sleepCSV, filename: "Feeling Sleepy.csv"))

    if !timesInBed.isEmpty {
      let timesInBedCSV = makeCSV(
        headers: "start time,end time,duration",
        data: timesInBed, line: { line in
          "\(line.start.stringValue),\(line.end.stringValue),\(line.duration)\n"
        }
      )
      csvFilesAndNames.append((data: timesInBedCSV, filename: "Bedtimes.csv"))
    }

  //    URLSession.shared.dataTask(with: URL(string: "https://localhost:3000/")!) { d, r, e in
  //      print(d, r, e)
  //    }.resume()

    let localIP = "10.0.0.166"
    api.request(
      RemoteStoreAPI(
        baseURL: URL(string: "http://\(localIP):3000/")!,
        endpoint: .uploadData(csvFiles: csvFilesAndNames, csvURLs: csvFiles)
      )) { result in
        switch result {
        case .success(let response):
          print(response, self)
        case .failure(let error):
          fatalError(error.localizedDescription)
        }
      }
  }

  func makeCSV<T>(headers: String, data: [T], line: (T) -> String) -> Data {
    var csv = "\(headers)\n"
    for sample in data {
      csv += "\(line(sample))\n"
    }
    guard let csvData = csv.data(using: .utf8) else { fatalError() }

    return csvData
  }
}
