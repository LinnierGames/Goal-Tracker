//
//  HabitPickerScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/15/23.
//

import SwiftUI

struct HabitPickerScreen: View {
  let title: String
  let subtitle: String
  let didPick: (Habit) -> Void
  let disabled: (Habit) -> Bool

  @FetchRequest(sortDescriptors: [SortDescriptor(\Habit.title)])
  private var habits: FetchedResults<Habit>

  init(
    title: String,
    subtitle: String,
    didPick: @escaping (Habit) -> Void,
    disabled: @escaping (Habit) -> Bool = { _ in false }
  ) {
    self.title = title
    self.subtitle = subtitle
    self.didPick = didPick
    self.disabled = disabled
  }

  var body: some View {
    NavigationView {
      List(habits) { habit in
        let isDisabled = disabled(habit)
        HStack {
          Text(habit.title!)
            .foregroundColor(isDisabled ? .gray : .black)
          Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
          didPick(habit)
        }
        .disabled(isDisabled)
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          VStack {
            Text(title).font(.headline)
            Text(subtitle).font(.subheadline)
          }
        }
      }
    }
  }
}
