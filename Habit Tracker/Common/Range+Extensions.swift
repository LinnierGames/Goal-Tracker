//
//  Range+Extensions.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/26/23.
//

import Foundation

extension Range {
  func map<MappedValue>(_ transform: (Bound, Bound) -> Range<MappedValue>) -> Range<MappedValue> {
    transform(lowerBound, upperBound)
  }
}

extension ClosedRange {
  func map<MappedValue>(_ transform: (Bound, Bound) -> ClosedRange<MappedValue>) -> ClosedRange<MappedValue> {
    transform(lowerBound, upperBound)
  }
}
