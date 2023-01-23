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

protocol OptionalType: ExpressibleByNilLiteral {
  associatedtype Wrapped
  var optional: Wrapped? { get set }
}
extension Optional: OptionalType {
  var optional: Wrapped? {
    get { return self }
    mutating set { self = newValue }
  }
}

extension Binding where Value: OptionalType {
  func mapOptional(
    defaultValue: Value.Wrapped
  ) -> Binding<Value.Wrapped> {
    Binding<Value.Wrapped>(
      get: { self.wrappedValue.optional ?? defaultValue },
      set: { newValue in self.wrappedValue.optional = .some(newValue) }
    )
  }
}
