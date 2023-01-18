//
//  HabitDetailsSettingsScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/17/23.
//

import SwiftUI

struct HabitDetailsSettingsScreen: View {
  @ObservedObject var habit: Habit

//  @FocusState private var isTitleFocused
  @Environment(\.managedObjectContext) private var viewContext

  init(_ habit: Habit) {
    self.habit = habit
  }

  var body: some View {
    NavigationView {
      List {
        Section {
          HStack {
            Label("Title", systemImage: "text.book.closed")
            TextField("Title", text: $habit.title.map(get: { $0 ?? "" }, set: { $0 }))
//              .focused($isTitleFocused)
              .multilineTextAlignment(.trailing)
              .onSubmit {
                try! viewContext.save()
              }
              .submitLabel(.done)
          }
        }

        Section {
          HStack {
            Label("Start Date", systemImage: "calendar")
            Spacer()
            Text("Apr 22, 2022")
          }
          HStack {
            Label("Due", systemImage: "checkmark.square")
            Spacer()
            Text("Weekdays")
          }
        }
      }
      .listStyle(.grouped)

//      .toolbar {
//        Button("Done") {
//          isTitleFocused = false
//          try! viewContext.save()
//        }.isHidden(!isTitleFocused)
//      }
      .navigationTitle(habit.title!)
    }
  }
}
