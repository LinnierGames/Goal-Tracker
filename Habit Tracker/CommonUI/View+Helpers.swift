//
//  View+Helpers.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 3/19/22.
//

import SwiftUI

extension View {
  @ViewBuilder
  func isHidden(_ condition: Bool) -> some View {
    if condition {
      self.hidden()
    } else {
      self
    }
  }
}

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

  func navigationBarHeadline(_ headline: String, subheadline: String) -> some View {
    self
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          VStack {
            Text(headline).font(.headline)
            Text(subheadline).font(.subheadline)
          }
          .foregroundColor(.primary)
        }
      }
  }

  @ViewBuilder public func `if`<T>(_ condition: Bool, transform: (Self) -> T) -> some View where T: View {
      if condition {
          transform(self)
      } else {
          self
      }
  }

  @ViewBuilder public func ifLet<T, G>(_ optional: G?, transform: (Self, G) -> T) -> some View where T: View {
      if let unwrapped = optional {
          transform(self, unwrapped)
      } else {
          self
      }
  }

  func item<Item, Content: View>(
    _ item: Item,
    @ViewBuilder modifer: (Self, Item) -> Content
  ) -> some View {
    modifer(self, item)
  }
}

import Charts

extension ChartContent {
  @ChartContentBuilder public func `if`<T>(_ condition: Bool, transform: (Self) -> T) -> some ChartContent where T: ChartContent {
      if condition {
          transform(self)
      } else {
          self
      }
  }
}
