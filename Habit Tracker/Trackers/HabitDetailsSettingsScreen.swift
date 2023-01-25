//
//  HabitDetailsSettingsScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/17/23.
//

import SwiftUI

struct HabitDetailsSettingsScreen: View {
  @ObservedObject var habit: Habit

  @State private var habitTitle: String
  @Environment(\.managedObjectContext)
  private var viewContext

  init(_ habit: Habit) {
    self.habit = habit

    // FIXME: deleting the tracker crashes here
    self._habitTitle = State(initialValue: habit.title!)
  }

  var body: some View {
    NavigationView {
      List {
        Section {
          HStack {
            Label("Title", systemImage: "text.book.closed")
            TextField("Title", text: $habitTitle)
              .multilineTextAlignment(.trailing)
              .onSubmit {
                habit.title = habitTitle
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

        Section {
          ActionSheetLink(title: "Delete Tracker") {
            Button("Delete Tracker", role: .destructive) {
              viewContext.delete(habit)
              try! viewContext.save()
            }
          } message: {
            Text("Deleting this tracker will delete logs and links to goals. Are you sure?")
          } label: {
            HStack {
              Spacer()
              Text("Delete Habit")
                .foregroundColor(.red)
              Spacer()
            }
          }
        }
      }
      .listStyle(.grouped)
      .navigationTitle(habit.title!)

      .onChange(of: habit.showInTodayView) { _ in
        try! viewContext.save()
      }
    }
  }
}
