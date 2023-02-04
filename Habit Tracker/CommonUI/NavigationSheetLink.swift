//
//  NavigationSheetLink.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/24/23.
//

import SwiftUI

struct NavigationSheetLink<Destination: View, Label: View>: View {
  let buttonOnly: Bool
  let destination: () -> Destination
  let label: () -> Label

  @State private var isShowingSheet = false

  init(
    buttonOnly: Bool = false,
    @ViewBuilder destination: @escaping () -> Destination,
    @ViewBuilder label: @escaping () -> Label
  ) {
    self.buttonOnly = buttonOnly
    self.destination = destination
    self.label = label
  }

  var body: some View {
    Group {
      if buttonOnly {
        label()
      } else {
        HStack {
          label()

          Spacer()

          Image(systemName: "chevron.right")
            .foregroundColor(.gray)
        }
      }
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
