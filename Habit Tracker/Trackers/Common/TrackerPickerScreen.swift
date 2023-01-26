//
//  TrackerPickerScreen.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/15/23.
//

import SwiftUI

struct TrackerPickerScreen: View {
  let title: String
  let subtitle: String
  let didPick: (Tracker) -> Void
  let disabled: (Tracker) -> Bool

  @FetchRequest(sortDescriptors: [SortDescriptor(\Tracker.title)])
  private var trackers: FetchedResults<Tracker>

  @Environment(\.dismiss)
  private var dismiss

  init(
    title: String,
    subtitle: String,
    didPick: @escaping (Tracker) -> Void,
    disabled: @escaping (Tracker) -> Bool = { _ in false }
  ) {
    self.title = title
    self.subtitle = subtitle
    self.didPick = didPick
    self.disabled = disabled
  }

  var body: some View {
    NavigationView {
      List(trackers) { tracker in
        let isDisabled = disabled(tracker)
        HStack {
          Text(tracker.title!)
            .foregroundColor(isDisabled ? .primary.opacity(0.35) : .primary)
          Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
          didPick(tracker)
          dismiss()
        }
        .disabled(isDisabled)
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          VStack {
            Text(title).font(.headline)
            Text(subtitle).font(.subheadline)
          }
        }
      }
    }
  }
}
