//
//  SheetLink.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/15/23.
//

import SwiftUI

struct SheetLink<Destination: View, Label: View>: View {
  let fullScreen: Bool
  let destination: Destination
  let label: Label

  @State private var isShowingSheet = false

  init(fullScreen: Bool = false, @ViewBuilder destination: () -> Destination, @ViewBuilder label: () -> Label) {
    self.fullScreen = fullScreen
    self.destination = destination()
    self.label = label()
  }

  var body: some View {
    Button {
      isShowingSheet.toggle()
    } label: {
      label
    }
    .if(fullScreen) {
      $0.fullScreenCover(isPresented: $isShowingSheet) {
        destination
      }
    }.if(!fullScreen) {
      $0.sheet(isPresented: $isShowingSheet) {
        destination
      }
    }
  }
}
