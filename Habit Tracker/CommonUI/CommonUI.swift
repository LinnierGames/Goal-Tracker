//
//  CommonUI.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 10/25/23.
//

import SwiftUI

struct TextEditorScreen: View {
  @Binding var text: String
  @State private var textfield = ""

  @FocusState private var isFocused

  var body: some View {
    Form {
      Section {
        TextEditor(text: $textfield)
          .frame(height: 196)
          .focused($isFocused)
      }
    }
    .onAppear {
      textfield = text

      if textfield.isEmpty {
        isFocused = true
      }
    }
    .onDisappear {
      text = textfield
    }
  }
}

extension FormatStyle where Self == TimeDateFormatStyle {
  static var time: TimeDateFormatStyle {
    TimeDateFormatStyle()
  }
}

struct TimeDateFormatStyle: FormatStyle, Codable, Hashable {
  func format(_ value: Date) -> String {
    DateFormatter.localizedString(from: value, dateStyle: .none, timeStyle: .short)
  }
}

extension FormatStyle where Self == DateFormatStyle {
  static func format(_ format: String) -> DateFormatStyle {
    DateFormatStyle(format: format)
  }
}

struct DateFormatStyle: FormatStyle, Codable, Hashable {
  let format: String

  func format(_ value: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return formatter.string(from: value)
  }
}

extension FormatStyle where Self == DurationFormatStyle {
  static var duration: DurationFormatStyle {
    DurationFormatStyle(unitsOverride: [])
  }

  static func duration(units: NSCalendar.Unit = []) -> DurationFormatStyle {
    DurationFormatStyle(unitsOverride: units)
  }
}

extension NSCalendar.Unit: Codable, Hashable {}

struct DurationFormatStyle: FormatStyle, Codable, Hashable {
  let unitsOverride: NSCalendar.Unit

  func format(_ seconds: Double) -> String {
    let formatter = DateComponentsFormatter()

    if unitsOverride.isEmpty {
      if seconds >= 60 {
        formatter.allowedUnits = [.hour, .minute]
      } else {
        formatter.allowedUnits = [.second]
      }
    } else {
      formatter.allowedUnits = unitsOverride
    }

    formatter.unitsStyle = .short
    let seconds = DateComponents(second: Int(seconds))

    return formatter.string(from: seconds) ?? "0 min"
  }
}
