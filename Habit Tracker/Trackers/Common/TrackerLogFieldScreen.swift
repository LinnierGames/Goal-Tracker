//
//  TrackerLogFieldScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/29/23.
//

import SwiftUI

struct TrackerLogFieldScreen: View {
  static func newField(didFinish: @escaping (String, TrackerLogFieldType) -> Void) -> Self {
    TrackerLogFieldScreen(navTitle: "New Field", fieldTitle: "", selectedFieldType: .string, didFinish: didFinish)
  }
  static func editField(_ field: TrackerLogField, didFinish: @escaping (String, TrackerLogFieldType) -> Void) -> Self {
    TrackerLogFieldScreen(navTitle: "Edit Field", fieldTitle: field.title!, selectedFieldType: field.type, didFinish: didFinish)
  }

  var navTitle: String
  @State var fieldTitle: String
  @State var selectedFieldType: TrackerLogFieldType
  var didFinish: (String, TrackerLogFieldType) -> Void

  @Environment(\.dismiss) var dismiss

//  private init(
//    fieldTitle: String,
//    selectedFieldType: TrackerLogFieldType
//  ) {
//    self._fieldTitle = State(initialValue: fieldTitle)
//    self._selectedFieldType = State(initialValue: selectedFieldType)
//  }

  var body: some View {
    NavigationView {
      List {
        Section {
          HStack {
            Label("Title", systemImage: "text.book.closed")
            TextField("Title", text: $fieldTitle)
              .multilineTextAlignment(.trailing)
              .submitLabel(.done)
          }
        }

        Section("Field Type") {
          ForEach(TrackerLogFieldType.allCases) { type in
            Button(action: { selectedFieldType = type }) {
              HStack {
                Text(type.description)
                  .foregroundColor(.primary)
                Spacer()
                if selectedFieldType == type {
                  Image(systemName: "checkmark")
                }
              }
            }
          }
        }
      }
      .toolbar {
        Button("Save") {
          didFinish(fieldTitle, selectedFieldType)
          dismiss()
        }
      }

      .navigationBarTitleDisplayMode(.inline)
      .navigationTitle(navTitle)
    }
  }
}
