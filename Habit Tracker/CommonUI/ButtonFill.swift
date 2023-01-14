//
//  ButtonFill.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/14/23.
//

import SwiftUI

struct ButtonFill: View {
  let text: String
  let fill: Color
  let action: () -> Void

  init(_ text: String, fill: Color, action: @escaping () -> Void) {
    self.text = text
    self.fill = fill
    self.action = action
  }

  @Environment(\.isEnabled) var isEnabled

  var body: some View {
    Button(action: action, label: {
      HStack {
        Spacer()
        Text(text)
          .foregroundColor(.white)
        Spacer()
      }
      .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
      .background(isEnabled ? fill : fill.opacity(0.55))
      .cornerRadius(12)
    })
  }
}
