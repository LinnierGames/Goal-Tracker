//
//  GoalsScreen.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/15/23.
//

import Charts
import CoreData
import SwiftUI

struct GoalsScreen: View {
  @State private var isNewGoalAlertShowing = false
  @State private var newGoalTitle = ""

  @AppStorage("SHOW_TRACKERS_IN_GOALS") private var showTrackers = true

  @FetchRequest(sortDescriptors: [SortDescriptor(\.title)])
  private var goals: FetchedResults<Goal>

  @Environment(\.managedObjectContext)
  private var viewContext

  var body: some View {
    NavigationView {
      ScrollView {
        LazyVStack {
          ForEach(goals) { goal in
            GoalCellDetailView(goal, showTrackers: showTrackers)
          }
        }
        .navigationTitle("Goals")
        .toolbar {
          Button { withAnimation { showTrackers.toggle() } } label: {
            Image(systemName: showTrackers ? "eye.fill" : "eye")
          }
          Button { isNewGoalAlertShowing = true } label: {
            Image(systemName: "plus")
          }
        }
      }
      .padding(.horizontal)
    }
    .alert("Add Goal", isPresented: $isNewGoalAlertShowing, actions: {
      TextField("Title", text: $newGoalTitle)
      Button("Cancel", role: .cancel, action: {})
      Button("Add", action: addNewGoal)
    }, message: {
      Text("enter the title for your new goal")
    })
  }

  private func addNewGoal() {
    guard !newGoalTitle.isEmpty else { return }

    let newGoal = Goal(context: viewContext)
    newGoal.title = newGoalTitle

    try! viewContext.save()

    newGoalTitle = ""
  }
}

private struct GoalCellDetailView: View {
  @ObservedObject var goal: Goal

  let showTrackers: Bool

  @FetchRequest
  private var sections: FetchedResults<GoalChartSection>

  @FetchRequest
  private var trackers: FetchedResults<GoalTrackerCriteria>

  init(_ goal: Goal, showTrackers: Bool) {
    self.goal = goal
    self.showTrackers = showTrackers
    self._sections = FetchRequest(
      sortDescriptors: [SortDescriptor(\.title)],
      predicate: NSPredicate(format: "goal = %@", goal)
    )
    self._trackers = FetchRequest(
      sortDescriptors: [SortDescriptor(\.tracker?.title)],
      predicate: NSPredicate(format: "goal = %@", goal)
    )
  }

  var body: some View {
    VStack {
      SheetLink {
        GoalDetailScreen(goal)
      } label: {
        VStack(alignment: .leading) {
          HStack {
            Text(goal.title!)
              .foregroundColor(.primary)
              .font(.title2)
          }

          // Goal sections names and chart
          HStack(alignment: .top) {
            VStack(alignment: .leading) {
              ForEach(sections) { section in
                Text(section.title!)
              }
            }
            .foregroundColor(.primary)
            .font(.caption)
            Spacer()
            RandomChart(.line)
              .frame(width: 164, height: 32)
          }
        }
      }

      // All trackers
      if showTrackers {
        ScrollView {
          LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
            ForEach(trackers.map(\.tracker!)) { tracker in
              TrackerGridRow(tracker: tracker)
            }
          }
        }
        .transition(.opacity)
      }
    }
    .padding()
    .background(Color.secondary.opacity(0.2))
    .cornerRadius(12)
  }
}

private struct TrackerGridRow: View {
  @ObservedObject var tracker: Tracker

  @Environment(\.managedObjectContext)
  private var viewContext

  var body: some View {
    SheetLink {
      TrackerDetailScreen(tracker)
    } label: {
      HStack(spacing: 0) {
        Text(tracker.title ?? "Untitled")
          .foregroundColor(.primary)
          .font(.caption2)
          .lineLimit(1)
          .padding(.trailing, 2)

        Spacer(minLength: 0)
        MostRecentLog(tracker: tracker, isToday: true) { log in
          SheetLink {
            NavigationView {
              TrackerLogDetailScreen(tracker: tracker, log: log)
            }
          } label: {
            Image(systemName: "bookmark.circle")
              .foregroundColor(.primary)
          }
        }
        Image(systemName: "chevron.forward")
          .foregroundColor(.primary)
      }
      .padding(6)
      .background(Color.secondary.opacity(0.5))
      .cornerRadius(8)

      .contextMenu {
        Button(
          action: {
            let newLog = TrackerLog(context: viewContext)
            newLog.timestamp = Date()
            tracker.addToLogs(newLog)

            try! viewContext.save()
          },
          title: "Add Log",
          systemImage: "plus"
        )
      }
    }
  }
}
