//
//  ReportsScreen.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 3/18/22.
//

import SwiftUI

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

      .onLoad {
        viewModel.fetchReports(host: hostString)
      }
      .refreshable {
        await viewModel.fetchReports(host: hostString)
      }
    }
  }
}
