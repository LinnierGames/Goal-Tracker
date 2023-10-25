//
//  CommonUI.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 10/25/23.
//

import SwiftUI

struct TextEditorScreen: View {
  @Binding var text: String
  @State private var textfield = ""

  @FocusState private var isFocused

  var body: some View {
    Form {
      Section {
        TextEditor(text: $textfield)
          .frame(height: 196)
          .focused($isFocused)
      }
    }
    .onAppear {
      textfield = text

      if textfield.isEmpty {
        isFocused = true
      }
    }
    .onDisappear {
      text = textfield
    }
  }
}
