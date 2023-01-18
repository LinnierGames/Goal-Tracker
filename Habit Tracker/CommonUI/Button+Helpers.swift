//
//  Button+Helpers.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/17/23.
//

import SwiftUI

extension Button {
  init(action: @escaping () -> Void, systemImage: String) where Label == Image {
    self.init(action: action) {
      Image(systemName: systemImage)
    }
  }
}
