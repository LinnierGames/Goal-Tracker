//
//  GoalsScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/15/23.
//

import Charts
import CoreData
import SwiftUI

struct GoalsScreen: View {
  @State private var isNewGoalAlertShowing = false
  @State private var newGoalTitle = ""

  @FetchRequest(sortDescriptors: [SortDescriptor(\.title)])
  private var goals: FetchedResults<Goal>

  @Environment(\.managedObjectContext)
  private var viewContext

  var body: some View {
    NavigationView {
      List(goals) { goal in
        SheetLink {
          GoalDetailScreen(goal)
        } label: {
          VStack(alignment: .leading) {
            HStack {
              Text(goal.title!)
                .foregroundColor(.primary)
                .font(.title2)
            }

            HStack {
              VStack {
                Text("Goal")
                Text("Goal")
                Text("Goal")
              }
              .foregroundColor(.primary)
              .font(.caption)

              Spacer()

              RandomChart(.line)
                .frame(width: 164, height: 32)
                .padding(.vertical)
            }
          }
        }
      }
      .navigationTitle("Goals")
      .toolbar {
        Button { isNewGoalAlertShowing = true } label: {
          Image(systemName: "plus")
        }
      }
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

struct HI_Previews: PreviewProvider {
  static var previews: some View {
    List(0..<4) { _ in
    }
  }
}
