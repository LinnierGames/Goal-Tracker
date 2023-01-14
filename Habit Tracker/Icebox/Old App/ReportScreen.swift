//
//  ReportScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 3/19/22.
//

import SwiftUI

struct ReportScreen: View {
  let reportFile: RemoteReportFile

  @StateObject private var viewModel: ReportViewModel
  @State private var isShowingShareSheet = false

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
      Button(action: { isShowingShareSheet = true }) {
        Image(systemName: "square.and.arrow.up")
      }
    }

    .sheet(isPresented: $isShowingShareSheet) {
      if let url = viewModel.reportFilePath {
        ShareSheet(activityItems: [url])
      }
    }

    .onAppear {
      viewModel.fetch(reportFile)
    }
  }

  private func pressShare() {

  }
}
