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

struct EnvironmentView<T, V: View>: View {
  @Environment var environment: T
  let view: (T) -> V

  init(_ keyPath: KeyPath<EnvironmentValues, T>, @ViewBuilder view: @escaping (T) -> V) {
    self._environment = Environment(keyPath)
    self.view = view
  }

  var body: some View {
    view(environment)
  }
}

struct EnvironmentObjectView<T: ObservableObject, V: View>: View {
  @EnvironmentObject var environmentObject: T
  @ViewBuilder var view: (T) -> V

  init(_ object: T.Type, @ViewBuilder view: @escaping (T) -> V) {
    self._environmentObject = EnvironmentObject<T>()
    self.view = view
  }

  var body: some View {
    view(environmentObject)
  }
}
