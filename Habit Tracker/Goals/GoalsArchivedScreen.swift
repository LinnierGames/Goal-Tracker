//
//  GoalsArchivedScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 7/20/23.
//

import SwiftUI

struct GoalsArchivedScreen: View {
  @FetchRequest(
    sortDescriptors: [SortDescriptor(\.title)],
    predicate: NSPredicate(format: "isArchived == YES")
  )
  private var goals: FetchedResults<Goal>

  var body: some View {
    List {
      ForEach(goals) { goal in
        SheetLink {
          GoalDetailScreen(goal)
        } label: {
          Text(goal.title ?? "Untitled Goal")
        }
      }
    }
  }
}
