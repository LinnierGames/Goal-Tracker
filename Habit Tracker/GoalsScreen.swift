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
                .font(.title2)
            }

            HStack {
              VStack {
                Text("Goal")
                Text("Goal")
                Text("Goal")
              }
              .font(.caption)

              Spacer()

              Chart {
                LineMark(x: .value("x", "12 pm"), y: .value("count", (0..<10).randomElement()!))
                LineMark(x: .value("x", "1"), y: .value("count", (0..<10).randomElement()!))
                LineMark(x: .value("x", "2"), y: .value("count", (0..<10).randomElement()!))
                LineMark(x: .value("x", "3"), y: .value("count", (0..<10).randomElement()!))
              }
              .chartXAxis(.hidden)
              .chartYAxis(.hidden)
              .frame(width: 164, height: 32)
              .padding(.vertical)
              .background(Color.gray.opacity(0.25))
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
