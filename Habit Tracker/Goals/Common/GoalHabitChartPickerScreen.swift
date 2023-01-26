//
//  GoalHabitChartPickerScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/19/23.
//

import SwiftUI

struct GoalHabitChartPickerScreen: View {
  let title: String
  let subtitle: String
  let goal: Goal

  enum Chart {
    case habit(GoalHabitCriteria, ChartKind)
    case chart(Void) // TODO: Reference simple charts from the habit itself
  }
  let didPick: (Chart) -> Void

  @FetchRequest
  private var criterias: FetchedResults<GoalHabitCriteria>

  @Environment(\.dismiss) var dismiss

  init(title: String, subtitle: String, goal: Goal, didPick: @escaping (Chart) -> Void) {
    self.title = title
    self.subtitle = subtitle
    self.goal = goal
    self.didPick = didPick
    self._criterias = FetchRequest(
      sortDescriptors: [SortDescriptor(\GoalHabitCriteria.habit!.title)],
      predicate: NSPredicate(format: "goal = %@", goal)
    )
  }

  var body: some View {
    NavigationView {
      List(criterias) { criteria in
        HStack {
          Text(criteria.habit!.title!)
          Spacer()
          Menu {
            Button(
              action: {
                didPick(.habit(criteria, .count))
                dismiss()
              },
              title: "Count",
              systemImage: "chart.bar.fill"
            )

            Button(
              action: {
                didPick(.habit(criteria, .frequency))
                dismiss()
              },
              title: "Frequency",
              systemImage: "chart.xyaxis.line"
            )
          } label: {
            Text("Create New Chart")
              .font(.caption)
              .padding(.horizontal, 10)
              .padding(.vertical, 8)
              .background(Color.gray.opacity(0.15))
              .cornerRadius(8)
          }
//          Button {
//          } label: {
//          }
//          .buttonStyle(.bordered)
        }
        ForEach(0..<Int.random(in: 1...4)) { _ in
          HStack {
            Text("Random chart")
            Spacer()
            RandomChart(.line)
              .frame(width: 96, height: 32)
          }
          .padding(.leading, 16)
        }
      }
      .navigationBarHeadline(title, subheadline: subtitle)
    }
  }
}
