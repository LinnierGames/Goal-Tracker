//
//  Sort.swift
//  CloudWatching
//
//  Created by Erick Sanchez on 4/19/24.
//

import Foundation

public struct SortOptions: OptionSet {
  public let rawValue: Int

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }

  public static let sortNilsAtTheEnd = SortOptions(rawValue: 1 << 0)
}

extension Collection {
  public func sorted<C1: Comparable>(
    by c1: KeyPath<Element, C1>,
    order: SortOrder = .forward,
    options: SortOptions = []
  ) -> [Self.Element] {
    sorted(
      predicate: { left, right in
        try Self.evaluate(
          left: left, right: right, keyPath: c1, order: order, options: options
        )
      },
      order: order
    )
  }

  public func sorted<C1: Comparable, C2: Comparable>(
    by c1: KeyPath<Element, C1>, _ c2: KeyPath<Element, C2>,
    order: SortOrder = .forward,
    options: SortOptions = []
  ) -> [Self.Element] {
    sorted(
      predicate: { left, right in
        try Self.evaluate(
          left: left, right: right, keyPath: c1, order: order, options: options
        )
        try Self.evaluate(
          left: left, right: right, keyPath: c2, order: order, options: options
        )
      },
      order: order
    )
  }

  public func sorted<C1: Comparable, C2: Comparable, C3: Comparable>(
    by c1: KeyPath<Element, C1>, _ c2: KeyPath<Element, C2>, _ c3: KeyPath<Element, C3>,
    order: SortOrder = .forward,
    options: SortOptions = []
  ) -> [Self.Element] {
    sorted(
      predicate: { left, right in
        try Self.evaluate(
          left: left, right: right, keyPath: c1, order: order, options: options
        )
        try Self.evaluate(
          left: left, right: right, keyPath: c2, order: order, options: options
        )
        try Self.evaluate(
          left: left, right: right, keyPath: c3, order: order, options: options
        )
      },
      order: order
    )
  }

  private func sorted(
    predicate: (Element, Element) throws -> Void,
    order: SortOrder
  ) -> [Self.Element] {
    // TODO: Try iterating parameter packs in Swift 6
//  public func sorted<each Value: Comparable>(
//    by keyPaths: repeat KeyPath<Element, each Value>,
//    order: SortOrder = .forward,
//    options: SortOptions = []
//  ) -> [Self.Element] {
//    var count = 0
//    _ = (repeat (each keyPaths, count += 1))
//
//    guard count > 0 else { return Array(self) }

    return self.sorted(by: { (left, right) -> Bool in
      do {
        try predicate(left, right)
        // TODO: Try iterating parameter packs in Swift 6
//        repeat try Self.evaluate(
//          left: left, right: right, keyPath: each keyPaths, order: order, options: options
//        )

        // all key paths returned same order
        return true
      } catch ShortCircuit.forward {
        return true
      } catch ShortCircuit.reverse {
        return false
      } catch {
        fatalError("Unexpected error from evaluate, got \(error)")
      }

      // All key paths resulted the same comparison. Follow order
      return order == .forward
    })
  }

  public func sorted<C1: Comparable>(
    by c1: (keyPath: KeyPath<Element, C1>, order: SortOrder),
    order: SortOrder = .forward,
    options: SortOptions = []
  ) -> [Self.Element] {
    sorted(
      predicate: { left, right in
        try Self.evaluate(
          left: left, right: right, predicate: c1, options: options
        )
      },
      order: order
    )
  }

  public func sorted<C1: Comparable, C2: Comparable>(
    by c1: (keyPath: KeyPath<Element, C1>, order: SortOrder), _ c2: (keyPath: KeyPath<Element, C2>, order: SortOrder),
    order: SortOrder = .forward,
    options: SortOptions = []
  ) -> [Self.Element] {
    sorted(
      predicate: { left, right in
        try Self.evaluate(
          left: left, right: right, predicate: c1, options: options
        )
        try Self.evaluate(
          left: left, right: right, predicate: c2, options: options
        )
      },
      order: order
    )
  }

  public func sorted<C1: Comparable, C2: Comparable, C3: Comparable>(
    by c1: (keyPath: KeyPath<Element, C1>, order: SortOrder), _ c2: (keyPath: KeyPath<Element, C2>, order: SortOrder), _ c3: (keyPath: KeyPath<Element, C3>, order: SortOrder),
    order: SortOrder = .forward,
    options: SortOptions = []
  ) -> [Self.Element] {
    sorted(
      predicate: { left, right in
        try Self.evaluate(
          left: left, right: right, predicate: c1, options: options
        )
        try Self.evaluate(
          left: left, right: right, predicate: c2, options: options
        )
        try Self.evaluate(
          left: left, right: right, predicate: c3, options: options
        )
      },
      order: order
    )
  }

  private func sorted(
    predicate: (Element, Element) throws -> Void
  ) -> [Self.Element] {
    // TODO: Try iterating parameter packs in Swift 6
//  public func sorted<each Value: Comparable>(
//    by predicates: repeat (keyPath: KeyPath<Element, each Value>, order: SortOrder),
//    options: SortOptions = [] // TODO: Move options inside predicate
//  ) -> [Self.Element] {
//    var count = 0
//    _ = (repeat (each predicates, count += 1))
//
//    guard count > 0 else { return Array(self) }

    return self.sorted(by: { (left, right) -> Bool in
      do {
        try predicate(left, right)
        // TODO: Try iterating parameter packs in Swift 6
//        repeat try Self.evaluate(
//          left: left, right: right, predicate: each predicates, options: options
//        )

        // all key paths returned same order
        return true
      } catch ShortCircuit.forward {
        return true
      } catch ShortCircuit.reverse {
        return false
      } catch {
        fatalError("Unexpected error from evaluate, got \(error)")
      }

      // All key paths resulted the same comparison
      return true
    })
  }

  private static func evaluate<T: Comparable>(
    left: Element, right: Element, keyPath: KeyPath<Element, T>,
    order: SortOrder,
    options: SortOptions
  ) throws {
    if options.contains(.sortNilsAtTheEnd) {
      try sortNilsAtTheEnd(left: left, right: right, keyPath: keyPath)
    }

    if left[keyPath: keyPath] == right[keyPath: keyPath] {
      return // continue in unpack repeat
    } else {
      switch order {
      case .forward:
        throw left[keyPath: keyPath] < right[keyPath: keyPath]
          ? ShortCircuit.forward
          : ShortCircuit.reverse
      case .reverse:
        throw left[keyPath: keyPath] < right[keyPath: keyPath]
          ? ShortCircuit.reverse
          : ShortCircuit.forward
      }
    }
  }

  private static func evaluate<T: Comparable>(
    left: Element, right: Element, predicate: (keyPath: KeyPath<Element, T>, order: SortOrder),
    options: SortOptions
  ) throws {
    if left[keyPath: predicate.keyPath] == right[keyPath: predicate.keyPath] {
      return // continue in unpack repeat
    } else {
      if options.contains(.sortNilsAtTheEnd) {
        try sortNilsAtTheEnd(left: left, right: right, keyPath: predicate.keyPath)
      }

      switch predicate.order {
      case .forward:
        throw left[keyPath: predicate.keyPath] < right[keyPath: predicate.keyPath]
          ? ShortCircuit.forward
          : ShortCircuit.reverse
      case .reverse:
        throw left[keyPath: predicate.keyPath] < right[keyPath: predicate.keyPath] 
          ? ShortCircuit.reverse
          : ShortCircuit.forward
      }
    }
  }

  private static func sortNilsAtTheEnd<T>(left: Element, right: Element, keyPath: KeyPath<Element, T>) throws {
    let (isLeftAnOptional, left) = isOptional(left[keyPath: keyPath])
    let (isRightAnOptional, right) = isOptional(right[keyPath: keyPath])

    guard isLeftAnOptional && isRightAnOptional else {
      return
    }

    if left == nil && right != nil {
      throw ShortCircuit.reverse
    } else if right == nil && left != nil {
      throw ShortCircuit.forward
    }
  }

  private static func isOptional<T>(_ instance: T) -> (Bool, T?) {
    let mirror = Mirror(reflecting: instance)

    if mirror.displayStyle == .optional {
      if mirror.children.count == 0 {
        // .None
        return (true, nil)

      } else {
        // .Some
        let (_, some) = mirror.children.first!
        if let val = some as? T {
          return (true, val)
        } else {
          assertionFailure("Given instance, \(instance) is not of type G, \(T.self)")
          return (true, nil)
        }
      }
    } else {
      return (false, nil)
    }
  }
}

private enum ShortCircuit: Error {
  case forward, reverse
}

extension Optional: Comparable where Wrapped: Comparable {
  public static func < (lhs: Optional, rhs: Optional) -> Bool {
    guard let left = lhs else {
      return true
    }
    guard let right = rhs else {
      return false
    }

    // Sort based on the values
    return left < right
  }
}
