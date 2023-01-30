//
//  TrackerDetailsSettingsFieldsScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/29/23.
//

import SwiftUI

struct TrackerDetailsSettingsFieldsScreen: View {
  @ObservedObject var tracker: Tracker

  @FetchRequest
  private var fields: FetchedResults<TrackerLogField>

  @Environment(\.managedObjectContext)
  private var viewContext

  init(_ tracker: Tracker) {
    self.tracker = tracker

    self._fields = FetchRequest(
      sortDescriptors: [SortDescriptor(\TrackerLogField.title)],
      predicate: NSPredicate(format: "tracker = %@", tracker)
    )
  }

  var body: some View {
    List {
      ForEach(fields) { field in
        NavigationSheetLink {
          TrackerLogFieldScreen.editField(field) { title, type in
            field.title = title
            field.type = type
            try! viewContext.save()
          }
        } label: {
          HStack {
            Text(field.title!)
            Spacer()
            Text(field.type.description)
          }
        }
      }
    }
    .listStyle(.grouped)
    .toolbar {
      SheetLink {
        TrackerLogFieldScreen.newField { title, type in
          let newField = TrackerLogField(context: viewContext)
          newField.title = title
          newField.type = type
          tracker.addToFields(newField)

          try! viewContext.save()
        }
      } label: {
        Image(systemName: "plus")
      }
    }
    .navigationTitle("Fields")
    .navigationBarTitleDisplayMode(.inline)
  }
}
