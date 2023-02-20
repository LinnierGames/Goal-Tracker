//
//  TrackerDetailScreen.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/15/23.
//

import SwiftUI

struct TrackerDetailScreen: View {
  let dateRange: Date
  let dateRangeWindow: DateWindow

  @StateObject var tracker: Tracker
  @State var uiTabarController: UITabBarController?

  @Environment(\.dismiss) private var dismiss

  init(_ tracker: Tracker, dateRange: Date = Date(), dateRangeWindow: DateWindow = .week) {
    self.dateRange = dateRange
    self.dateRangeWindow = dateRangeWindow
    self._tracker = StateObject(wrappedValue: tracker)
  }

  var body: some View {
    TabView {
      TrackerDetailsChartScreen(tracker, dateRange: dateRange, dateRangeWindow: dateRangeWindow)
        .tabItem {
          Label("Analytics", systemImage: "chart.xyaxis.line")
        }

      TrackerDetailsHistoryScreen(tracker)
        .tabItem {
          Label("History", systemImage: "clock.arrow.circlepath")
        }

      TrackerDetailsSettingsScreen(tracker)
        .tabItem {
          Label("Tracker", systemImage: "figure.walk")
        }
    }

    // FIXME: this is not called in time for deleting
    .onChange(of: tracker.isDeleted, perform: { newValue in
      guard newValue else { return }
      dismiss()
    })
  }
}
