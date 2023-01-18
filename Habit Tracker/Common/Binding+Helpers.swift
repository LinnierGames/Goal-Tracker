//
//  Binding+Helper.swift
//  ios
//
//  Created by Erick Sanchez on 1/17/21.
//

import SwiftUI

extension Binding {
  public func map<MappedValue>(
    get: @escaping (Value) -> MappedValue,
    set: @escaping (MappedValue) -> Value
  ) -> Binding<MappedValue> {
    Binding<MappedValue>(
      get: { get(self.wrappedValue) },
      set: { newValue in self.wrappedValue = set(newValue) }
    )
  }

  /// Maps the receiver to an optional of itself though if the binder sets a nil value, `defaultValue` is used
  public func mapIntoOptional(
    defaultValue: Value
  ) -> Binding<Value?> {
    Binding<Value?>(
      get: { self.wrappedValue as Value? },
      set: { newValue in self.wrappedValue = newValue ?? defaultValue }
    )
  }

  public init(get: @escaping () -> Value) {
    self.init(get: get, set: { _ in })
  }
}
