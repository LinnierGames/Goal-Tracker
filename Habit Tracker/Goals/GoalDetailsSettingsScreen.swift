//
//  GoalDetailsSettingsScreen.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/24/23.
//

import SwiftUI

struct GoalDetailsSettingsScreen: View {
  @ObservedObject var goal: Goal

  @State private var goalTitle: String

  @Environment(\.managedObjectContext)
  private var viewContext

  init(_ goal: Goal) {
    self.goal = goal
    self._goalTitle = State(initialValue: goal.title!)
  }

  var body: some View {
    NavigationView {
      List {
        Section {
          HStack {
            Label("Title", systemImage: "star.fill")
            TextField("Title", text: $goalTitle)
              .multilineTextAlignment(.trailing)
              .onSubmit {
                goal.title = goalTitle
                try! viewContext.save()
              }
              .submitLabel(.done)
          }
        }

        Section {
          NavigationLink {
            GoalDetailsSettingsTrackersScreen(goal)
          } label: {
            Label("Linked Trackers", systemImage: "text.book.closed")
          }
        }

        Section {
          HStack {
            Spacer()
            Button(goal.isArchived ? "Unarchive Goal" : "Archive Goal") {
              goal.isArchived.toggle()
              try! viewContext.save()
            }
            Spacer()
          }

          ActionSheetLink(title: "Delete Goal") {
            Button("Delete Goal", role: .destructive) {
              viewContext.delete(goal)
              try! viewContext.save()
            }
          } message: {
            Text("Deleting this goal will delete charts, sections, and remove links from trackers. Are you sure?")
          } label: {
            HStack {
              Spacer()
              Text("Delete Goal")
                .foregroundColor(.red)
              Spacer()
            }
          }
        }
      }
      .listStyle(.grouped)
      .navigationTitle(goal.title!)
    }
  }
}
