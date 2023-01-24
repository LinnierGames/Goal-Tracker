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

        Section {
          Toggle(isOn: $habit.showInTodayView) {
            Label("Show in Today View", systemImage: "calendar")
          }
        }

        Section {
          if let shortcut = ShortcutManager.shared.voiceShortcut(
            for: habit.objectID.uriRepresentation()
          ) {
            SiriButton(voiceShortcut: shortcut)
          } else {
            SiriButton(
              intent: ShortcutManager.shared.intent(
                for: .logTrackerIntent(habit)
              )
            )
          }
        }
        .listSectionSeparator(.hidden)
        .listRowBackground(EmptyView())
//        .onAppear {
//          let intent = ShortcutManager.Shortcut.logTrackerIntent(habit).intent
//          ShortcutManager.shared.donate(intent)
//        }
      }
      .listStyle(.grouped)

//      .toolbar {
//        Button("Done") {
//          isTitleFocused = false
//          try! viewContext.save()
//        }.isHidden(!isTitleFocused)
//      }
      .navigationTitle(habit.title!)

      .onChange(of: habit.showInTodayView) { _ in
        try! viewContext.save()
      }
    }
  }
}
