//
//  TrackerEntryDetailScreen.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/22/23.
//

import CoreData
import SwiftUI

struct TrackerEntryDetailScreen: View {
  @ObservedObject var tracker: Tracker
  @ObservedObject var entry: TrackerLog

  @Environment(\.managedObjectContext)
  private var viewContext

  @Environment(\.dismiss)
  private var dismiss

  var body: some View {
    List {
      DatePicker(selection: $entry.timestamp.mapOptional(defaultValue: Date())) {
        Label("Date", systemImage: "calendar")
      }
    }
    .listStyle(.grouped)
    .navigationTitle("Edit Entry")

    .onChange(of: entry.timestamp) { _ in
      try! viewContext.save()
    }
  }
}
