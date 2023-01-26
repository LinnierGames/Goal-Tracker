//
//  SheetLink.swift
//  Tracker Tracker
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
    Button {
      isShowingSheet.toggle()
    } label: {
      label
    }
    .sheet(isPresented: $isShowingSheet) {
      destination
    }
  }
}
