//
//  Networking.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 3/15/22.
//

import Foundation
import Moya
import UIKit

enum NetworkingError: Error {
  case nothingToUpload
}

class Networking {
  static let shared = Networking()

  let api = MoyaProvider<RemoteStoreAPI>()

  init() {
    api.session.sessionConfiguration.timeoutIntervalForRequest = 2
  }

  func uploadData(csvFiles: [CSVFile], csvFileURLs: [URL], to host: String) async throws {
    guard !csvFiles.isEmpty || !csvFileURLs.isEmpty else { throw NetworkingError.nothingToUpload }

    return try await withCheckedThrowingContinuation { continuation in
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

  func reports(from host: URL) async throws -> [RemoteReportFile] {
    return try await withCheckedThrowingContinuation { continuation in
      api.request(RemoteStoreAPI(baseURL: host, endpoint: .listOfReports)) { result in
        switch result {
        case .success(let response):
          let decoder = JSONDecoder()
          guard let strings = try? decoder.decode([RemoteReportFile].self, from: response.data) else {
            assertionFailure("failed to decode")
            continuation.resume(returning: [])
            return
          }

          continuation.resume(returning: strings)
        case .failure(let error):
          continuation.resume(with: .failure(error))
        }
      }
    }
  }

  func report(_ file: RemoteReportFile) async throws -> URL {
    let request = try URLRequest(url: file.url, method: .get, headers: ["key": "635452ba20a7780588a9367a21f971cfd7a"])
    let (originalURL, _) = try await URLSession.shared.download(for: request)

    let fileManager = FileManager.default
    let downloadsURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
    let filename = originalURL.lastPathComponent.split(separator: ".").first!
    let pdfFilename = "\(filename).pdf"

    let destinationURL = downloadsURL.appendingPathComponent(pdfFilename)

    do {
      print(originalURL, destinationURL)
      try fileManager.moveItem(at: originalURL, to: destinationURL)
      return destinationURL
    } catch {
      assertionFailure(error.localizedDescription)
      return originalURL
    }
  }
}
