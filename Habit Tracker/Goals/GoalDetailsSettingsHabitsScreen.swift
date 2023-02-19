//
//  GoalDetailsSettingsTrackersScreen.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/16/23.
//

import SwiftUI

struct GoalDetailsSettingsTrackersScreen: View {
  @ObservedObject var goal: Goal

  @FetchRequest
  private var trackerCriterias: FetchedResults<GoalTrackerCriteria>

  @State private var isShowingAddTrackerPicker = false

  @Environment(\.managedObjectContext)
  private var viewContext

  init(_ goal: Goal) {
    self.goal = goal
    self._trackerCriterias = FetchRequest(
      sortDescriptors: [SortDescriptor(\GoalTrackerCriteria.tracker!.title)],
      predicate: NSPredicate(format: "goal = %@", goal)
    )
  }

  var body: some View {
    List {
      Section("Trackers") {
        ForEach(trackerCriterias) { criteria in
          NavigationSheetLink {
            TrackerDetailScreen(criteria.tracker!)
          } label: {
            Text(criteria.tracker!.title!)
          }
          .swipeActions {
            Button {
              withAnimation {
                viewContext.delete(criteria)
                try! viewContext.save()
              }
            } label: {
              Text("Remove")
            }
          }
        }
      }
    }
    .toolbar {
      SheetLink {
        TrackerPickerScreen(
          title: "Select Tracker to Add",
          subtitle: goal.title!,
          didPick: { tracker in
            isShowingAddTrackerPicker = false

            let newTracker = GoalTrackerCriteria(context: viewContext)
            newTracker.tracker = tracker
            newTracker.goal = goal

            goal.addToTrackers(newTracker)

            try! viewContext.save()
          }, disabled: { tracker in
            trackerCriterias.map(\.tracker).contains(where: { $0 == tracker })
          }, disabledReason: { _ in "already added" }
        )
      } label: {
        Image(systemName: "plus")
      }
    }
    .navigationTitle("Linked Trackers")
  }

  private func removeTrackerFromGoal(indexes: IndexSet) {
    withAnimation {
      let trackerToRemove = trackerCriterias[indexes.first!]
      viewContext.delete(trackerToRemove)
      try! viewContext.save()
    }
  }
}
