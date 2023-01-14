//
//  ReportsViewModel.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 3/19/22.
//

import SwiftUI

@MainActor
class ReportsViewModel: ObservableObject {
  @Published var isLoading = false
  @Published var reportTitles = [RemoteReportFile]()
  @Published var alert: AlertContent?

  private let networking = Networking.shared

  func fetchReports(host: String) {
    Task {
      await fetchReports(host: host)
    }
  }

  func fetchReports(host: String) async {
    guard !isLoading, let url = URL(string: host) else { return }

    isLoading = true
    do {
      let reports = try await networking.reports(from: url)
      reportTitles = reports
    } catch {
      alert = AlertContent(title: "Something Went Wrong", message: error.localizedDescription)
    }

    isLoading = false
  }
}
