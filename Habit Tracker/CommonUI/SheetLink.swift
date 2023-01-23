//
//  SheetLink.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/15/23.
//

import SwiftUI

struct SheetLink<Destination: View, Label: View>: View {
  let destination: Destination
  let label: Label

  @State private var isShowingSheet = false

  init(@ViewBuilder destination: () -> Destination, @ViewBuilder label: () -> Label) {
    self.destination = destination()
    self.label = label()
  }

  var body: some View {
    label
      .foregroundColor(.accentColor)
      .contentShape(Rectangle())
      .onTapGesture {
        isShowingSheet.toggle()
      }
      .sheet(isPresented: $isShowingSheet) {
        destination
      }
  }
}

struct AlertLink<Actions: View, Message: View, Label: View>: View {
  let title: String
  let actions: () -> Actions
  let message: () -> Message
  let label: () -> Label

  @State private var isPresented = false

  init(
    title: String,
    @ViewBuilder actions: @escaping () -> Actions,
    @ViewBuilder message: @escaping () -> Message,
    label: @escaping () -> Label
  ) {
    self.title = title
    self.actions = actions
    self.message = message
    self.label = label
  }

  var body: some View {
    label()
      .foregroundColor(.accentColor)
      .contentShape(Rectangle())
      .onTapGesture {
        isPresented.toggle()
      }
      .alert(title, isPresented: $isPresented, actions: actions, message: message)
  }
}
