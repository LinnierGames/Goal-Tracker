//
//  NavigationSheetLink.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/24/23.
//

import SwiftUI

struct NavigationSheetLink<Destination: View, Label: View>: View {
  let destination: () -> Destination
  let label: () -> Label

  @State private var isShowingSheet = false

  init(
    @ViewBuilder destination: @escaping () -> Destination,
    @ViewBuilder label: @escaping () -> Label
  ) {
    self.destination = destination
    self.label = label
  }

  var body: some View {
    HStack {
      label()

      Spacer()

      Image(systemName: "chevron.right")
        .foregroundColor(.gray)
    }
    .contentShape(Rectangle())
    .onTapGesture {
      isShowingSheet.toggle()
    }
    .sheet(isPresented: $isShowingSheet) {
      destination()
    }
  }
}
