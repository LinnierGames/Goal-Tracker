//
//  TrackerDetailsSettingsTagsScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 3/7/23.
//

import SwiftUI

struct TrackerDetailsSettingsTagsScreen: View {
  @ObservedObject var tracker: Tracker

  @FetchRequest
  private var tags: FetchedResults<TrackerTag>

  @State private var newTagTitle = ""

  @Environment(\.managedObjectContext)
  private var viewContext

  init(_ tracker: Tracker) {
    self.tracker = tracker

    self._tags = FetchRequest(
      sortDescriptors: [SortDescriptor(\TrackerTag.title)]
    )
  }

  struct Tag: Identifiable {
    var id: ObjectIdentifier {
      tag.id
    }

    let tag: TrackerTag
    let isSelected: Bool
  }

  var allTags: [Tag] {
    tags.map { tag in
      Tag(tag: tag, isSelected: tag.contains(tracker))
    }
  }

  var body: some View {
    List(allTags) { tag in
      HStack {
        Text(tag.tag.title!)
        Spacer()
        if tag.isSelected {
          Image(systemName: "checkmark")
        }
      }
      .contentShape(Rectangle())
      .onTapGesture {
        if tag.isSelected {
          tracker.removeFromTags(tag.tag)
          tag.tag.removeFromTrackers(tracker)
        } else {
          tracker.addToTags(tag.tag)
          tag.tag.addToTrackers(tracker)
        }

        try! viewContext.save()
      }
    }
    .toolbar {
      AlertLink(title: "Add Tag") {
        TextField("Title", text: $newTagTitle)
          .textInputAutocapitalization(.never)
        Button("Cancel", role: .cancel, action: {})
        Button("Add", action: addNewTag)
      } message: {
        Text("enter the title for your new tag")
      } label: {
        Image(systemName: "plus")
      }
    }
    .navigationTitle("Tags")
  }

  private func addNewTag() {
    let newTag = TrackerTag(context: viewContext)
    newTag.title = newTagTitle
    try! viewContext.save()
    newTagTitle = ""
  }
}
