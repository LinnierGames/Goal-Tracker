//
//  SwiftUI+Extensions.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 4/27/24.
//

import SwiftUI

struct StateView<T, V: View>: View {
  @State private var state: T
  let view: (T, Binding<T>) -> V

  init(_ state: T, @ViewBuilder view: @escaping (Binding<T>) -> V) {
    self._state = State(initialValue: state)
    self.view = { _, binding in view(binding) }
  }

  init(_ state: T, @ViewBuilder view: @escaping (T, Binding<T>) -> V) {
    self._state = State(initialValue: state)
    self.view = view
  }

  var body: some View {
    view(state, $state)
  }
}
