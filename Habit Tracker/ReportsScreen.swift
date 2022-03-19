//
//  ReportsScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 3/18/22.
//

import SwiftUI

@MainActor
class ReportsViewModel: ObservableObject {
  @Published var isLoading = false
  @Published var reportTitles = [RemoteReportFile]()
  @Published var alert: AlertContent?

  private let networking = Networking.shared

  func fetchReports(host: String) {
    guard let url = URL(string: host) else { return }

    isLoading = true
    Task {
      do {
        let reports = try await networking.reports(from: url)
        reportTitles = reports
      } catch {
        alert = AlertContent(title: "Something Went Wrong", message: error.localizedDescription)
      }

      isLoading = false
    }
  }
}

struct RemoteReportFile: Decodable {
  let filename: String
  let url: URL
}

struct ReportsScreen: View {
  @StateObject private var viewModel: ReportsViewModel

  @AppStorage("HOST_STRING") private var hostString = "http://10.0.0.166:3000"

  init() {
    self._viewModel = StateObject(wrappedValue: ReportsViewModel())
  }

  var body: some View {
    NavigationView {
      List(viewModel.reportTitles, id: \.filename) { file in
        NavigationLink(file.filename, destination: ReportScreen(reportFile: file))
      }
      .navigationTitle("Reports")

      .loadingIndicator(isShowing: viewModel.isLoading)
      .alert(content: $viewModel.alert)

      .onAppear {
        viewModel.fetchReports(host: hostString)
      }
    }
  }
}

@MainActor
class ReportViewModel: ObservableObject {
  @Published var isLoading = false
  @Published var reportFilePath: URL?
  @Published var alert: AlertContent?

  private let networking = Networking.shared

  func fetch(_ file: RemoteReportFile, from host: String) {
//    guard let url = URL(string: host) else { return }

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

struct ReportScreen: View {
  let reportFile: RemoteReportFile

  @StateObject private var viewModel: ReportViewModel
  @AppStorage("HOST_STRING") private var hostString = "http://10.0.0.166:3000"

  init(reportFile: RemoteReportFile) {
    self.reportFile = reportFile
    self._viewModel = StateObject(wrappedValue: ReportViewModel())
  }

  var body: some View {
    VStack {
      if let url = viewModel.reportFilePath {
        PDFView(url: url)
      }
    }
    .loadingIndicator(isShowing: viewModel.isLoading)
    .alert(content: $viewModel.alert)

    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle(reportFile.filename)

    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: pressShare) {
          Image(systemName: "share")
        }
      }
    }

    .onAppear {
      viewModel.fetch(reportFile, from: hostString)
    }
  }

  private func pressShare() {

  }
}
