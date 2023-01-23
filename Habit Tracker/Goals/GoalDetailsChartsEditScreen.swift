//
//  GoalDetailsChartsEditScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/22/23.
//

import CoreData
import SwiftUI

struct GoalDetailsChartsEditScreen: View {
  @ObservedObject var goal: Goal

  @FetchRequest
  private var sections: FetchedResults<GoalChartSection>

  @Environment(\.managedObjectContext)
  private var viewContext

  init(_ goal: Goal) {
    self.goal = goal
    self._sections = FetchRequest(
      sortDescriptors: [SortDescriptor(\GoalChartSection.title)], // TODO: manual sorting
      predicate: NSPredicate(format: "goal = %@", goal)
    )
  }

  var body: some View {
    NavigationView {
      List(sections) { section in
        Section(section.title!) {
          ForEach(section.allCharts) { chart in
            Text(chart.habit!.habit!.title!) // TODO: remove habit name
              .swipeActions {
                Button("Delete") {
                  withAnimation {
                    viewContext.delete(chart)
                    try! viewContext.save()
                  }
                }
              }
          }

          AlertLink(title: "Delete Section") {
            Button("Delete", role: .destructive) {
              withAnimation {
                viewContext.delete(section)
                try! viewContext.save()
              }
            }
          } message: {
            Text("Deleting this section will delete all charts. Are you sure?")
          } label: {
            HStack {
              Spacer()
              Text("Delete Section")
              Spacer()
            }
          }
        }
      }
      .navigationBarHeadline("Edit Charts", subheadline: "for \(goal.title!)")
    }
  }

  private func deleteChart(index: IndexSet) {
  }
}
