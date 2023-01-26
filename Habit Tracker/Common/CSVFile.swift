//
//  CSVFile.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 3/16/22.
//

import Foundation

struct CSVFile {
  let data: Data
  let filename: String
}

extension CSVFile {
  init<T>(
    data: [T],
    headers: String,
    filename: String,
    csvRowFactory: (T) -> String
  ) {
    self.data = Self.makeCSV(headers: headers, data: data, line: csvRowFactory)
    self.filename = filename
  }

  private static func makeCSV<T>(headers: String, data: [T], line: (T) -> String) -> Data {
    var csv = "\(headers)\n"
    for sample in data {
      csv += "\(line(sample))\n"
    }
    guard let csvData = csv.data(using: .utf8) else { fatalError() }

    return csvData
  }
}
