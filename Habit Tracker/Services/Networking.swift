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

  func uploadData(csvFiles: [CSVFile], csvFileURLs: [URL]) {
    let localIP = "10.0.0.166"
    api.request(
      RemoteStoreAPI(
        baseURL: URL(string: "http://\(localIP):3000/")!,
        endpoint: .uploadData(csvFiles: csvFiles, csvFileURLs: csvFileURLs)
      )) { result in
        switch result {
        case .success(let response):
          print(response, self)
        case .failure(let error):
          fatalError(error.localizedDescription)
        }
      }
  }
}
