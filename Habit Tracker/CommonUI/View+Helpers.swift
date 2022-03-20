//
//  View+Helpers.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 3/19/22.
//

import SwiftUI

private struct ViewDidLoadModifier: ViewModifier {
  let action: () -> Void

  @State private var didLoad = false

  func body(content: Content) -> some View {
    content
      .onAppear {
        if didLoad == false {
          didLoad = true
          action()
        }
      }
  }
}

extension View {
  func onLoad(perform action: @escaping () -> Void) -> some View {
    modifier(ViewDidLoadModifier(action: action))
  }
}
