//
//  TrackerDetailsSettingsScreen.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/17/23.
//

import SwiftUI

struct TrackerDetailsSettingsScreen: View {
  @ObservedObject var tracker: Tracker

  @State private var trackerTitle: String
  @Environment(\.managedObjectContext)
  private var viewContext

  init(_ tracker: Tracker) {
    self.tracker = tracker

    // FIXME: deleting the tracker crashes here
    self._trackerTitle = State(initialValue: tracker.title!)
  }

  var body: some View {
    NavigationView {
      List {
        Section {
          HStack {
            Label("Title", systemImage: "text.book.closed")
            TextField("Title", text: $trackerTitle)
              .multilineTextAlignment(.trailing)
              .onSubmit {
                tracker.title = trackerTitle
                try! viewContext.save()
              }
              .submitLabel(.done)
          }
          Toggle(isOn: $tracker.isBadTracker) {
            Label("Is Bad Tracker?", systemImage: tracker.isBadTracker ? "xmark.seal.fill" : "checkmark.seal.fill")
          }
          NavigationLink {
            TextEditorScreen(text: $tracker.notes.mapOptional(defaultValue: ""))
              .onDisappear {
                try! viewContext.save()
              }
          } label: {
            VStack(alignment: .leading, spacing: 12) {
              Label("Notes", systemImage: "square.text.square")
              if !(tracker.notes?.isEmpty ?? true) {
                Text(tracker.notes ?? "")
                  .lineLimit(10)
              }
            }
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
          NavigationLink {
            TrackerDetailsSettingsTagsScreen(tracker)
          } label: {
            HStack {
              Label("Tags", systemImage: "tag")
              Spacer()
              Text(tracker.tags!.count, format: .number)
            }
          }
          NavigationLink {
            TrackerDetailsSettingsFieldsScreen(tracker)
          } label: {
            HStack {
              Label("Custom Fields", systemImage: "line.3.horizontal")
              Spacer()
              Text(tracker.fields!.count, format: .number)
            }
          }
        }

        Section {
          Toggle(isOn: $tracker.showInTodayView) {
            Label("Show in Today View", systemImage: "calendar")
          }
        }

        Section {
          if let shortcut = ShortcutManager.shared.voiceShortcut(
            for: tracker.objectID.uriRepresentation()
          ) {
            SiriButton(voiceShortcut: shortcut)
          } else {
            SiriButton(
              intent: ShortcutManager.shared.intent(
                for: .logTrackerIntent(tracker)
              )
            )
          }
        }
        .listSectionSeparator(.hidden)
        .listRowBackground(EmptyView())

        Section {
          ActionSheetLink(title: "Delete Tracker") {
            Button("Delete Tracker", role: .destructive) {
              viewContext.delete(tracker)
              try! viewContext.save()
            }
          } message: {
            Text("Deleting this tracker will delete logs and links to goals. Are you sure?")
          } label: {
            HStack {
              Spacer()
              Text("Delete Tracker")
                .foregroundColor(.red)
              Spacer()
            }
          }
        }
      }
      .listStyle(.grouped)
      .navigationTitle(tracker.title!)

      .onChange(of: tracker.showInTodayView) {
        try! viewContext.save()
      }
      .onChange(of: tracker.isBadTracker) {
        try! viewContext.save()
      }
    }
  }
}
