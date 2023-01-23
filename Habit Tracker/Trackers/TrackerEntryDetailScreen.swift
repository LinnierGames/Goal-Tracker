//
//  TrackerEntryDetailScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/22/23.
//

import CoreData
import SwiftUI

struct TrackerEntryDetailScreen: View {
  @ObservedObject var tracker: Habit
  @ObservedObject var entry: HabitEntry

  @Environment(\.managedObjectContext)
  private var viewContext

  @Environment(\.dismiss)
  private var dismiss

  var body: some View {
    NavigationView {
      List {
        DatePicker(selection: $entry.timestamp.mapOptional(defaultValue: Date())) {
          Label("Date", systemImage: "calendar")
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .principal) {
            VStack {
              Text("Edit Entry").font(.headline)
              Text("for \(tracker.title!)").font(.subheadline)
            }
          }

          ToolbarItem(placement: .navigationBarTrailing) {
            Button("Done", action: dismiss.callAsFunction)
          }
        }
      }.listStyle(.grouped)
    }
    .onChange(of: entry.timestamp) { _ in
      try! viewContext.save()
    }
  }
}
