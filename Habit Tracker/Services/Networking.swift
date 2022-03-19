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

  func uploadData(csvFiles: [CSVFile], csvFileURLs: [URL], to host: String) async throws {
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      self.api.request(
        RemoteStoreAPI(
          baseURL: URL(string: host)!,
          endpoint: .uploadData(csvFiles: csvFiles, csvFileURLs: csvFileURLs)
        )) { result in
          switch result {
          case .success:
            continuation.resume(with: .success(()))
          case .failure(let error):
            continuation.resume(with: .failure(error))
          }
        }
    }
  }
}
