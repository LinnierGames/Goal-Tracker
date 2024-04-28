//
//  Sanitize+String.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 4/27/24.
//

import Foundation

protocol Sanitizable {
  func sanitize(_ options: Sanitize...) -> Self
}

enum Sanitize {
  case capitalized
  case whitespaceTrimmed
}

extension String: Sanitizable {
  func sanitize(_ options: Sanitize...) -> String {
    var sanitized = self

    for option in options {
      switch option {
      case .capitalized:
        sanitized = sanitized.capitalized
      case .whitespaceTrimmed:
        sanitized = sanitized.trimmingCharacters(in: .whitespacesAndNewlines)
      }
    }

    return sanitized
  }
}
