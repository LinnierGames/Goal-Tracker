//
//  RemoteStoreAPI.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 3/16/22.
//

import Foundation
import Moya

struct RemoteStoreAPI {
  enum Endpoint {
    case uploadData(csvFiles: [CSVFile], csvFileURLs: [URL])
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
      let csvFileParts = csvFiles.map { csvFile in
        MultipartFormData(
          provider: .data(csvFile.data),
          name: multipartName,
          fileName: csvFile.filename,
          mimeType: "text/plain"
        )
      }
      let csvURLParts = csvURLs.compactMap { url -> MultipartFormData? in
//        guard let data = try? Data(contentsOf: url) else { return nil }
//
//        return MultipartFormData(
//          provider: .data(data),
//          name: multipartName,
//          fileName: url.lastPathComponent,
//          mimeType: "text/plain"
//        )
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
