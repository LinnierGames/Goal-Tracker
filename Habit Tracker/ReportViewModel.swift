//
//  ReportViewModel.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 3/19/22.
//

import SwiftUI

@MainActor
class ReportViewModel: ObservableObject {
  @Published var isLoading = false
  @Published var reportFilePath: URL?
  @Published var alert: AlertContent?

  private let networking = Networking.shared

  func fetch(_ file: RemoteReportFile) {
    isLoading = true
    Task {
      do {
        let reportURL = try await networking.report(file)
        self.reportFilePath = reportURL
      } catch {
        alert = AlertContent(title: "Something Went Wrong", message: error.localizedDescription)
      }

      isLoading = false
    }
  }
}
