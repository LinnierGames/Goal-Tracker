//
//  GoalDetailsChartsEditScreen.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/22/23.
//

import CoreData
import SwiftUI

struct GoalDetailsChartsEditScreen: View {
  @ObservedObject var goal: Goal

  @State private var sectionToEdit: GoalChartSection?
  @State private var sectionTitle = ""

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
        Section {
          SectionOfCharts(section)

          ActionSheetLink(title: "Delete Section") {
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
        } header: {
          HStack {
            Text(section.title!)
              .foregroundColor(.gray)
            Spacer()
            Button("Edit") {
              sectionTitle = section.title!
              sectionToEdit = section
            }
            .font(.caption)
          }
        }
      }
      .navigationBarHeadline("Edit Charts", subheadline: "for \(goal.title!)")
      .ifLet(sectionToEdit, transform: { view, section in
        view.alert(
          "Section Title",
          isPresented: $sectionToEdit.map(get: { $0 != nil }, set: { _ in nil })
        ) {
            TextField("Title", text: $sectionTitle)
            Button("Cancel", role: .cancel, action: {})
            Button("Save") {
              section.title = sectionTitle
              try! viewContext.save()
            }
          } message: {
            Text("enter a new title")
          }
      })
    }
  }
}

private struct SectionOfCharts: View {
  @ObservedObject var section: GoalChartSection

  @FetchRequest
  private var charts: FetchedResults<GoalChart>

  @Environment(\.managedObjectContext)
  private var viewContext

  init(_ section: GoalChartSection) {
    self.section = section
    self._charts = FetchRequest(
      sortDescriptors: [SortDescriptor(\GoalChart.tracker!.tracker!.title)], // TODO: manual sorting
      predicate: NSPredicate(format: "section = %@", section)
    )
  }


  var body: some View {
    ForEach(charts) { chart in
      NavigationLink {
        GoalDetailsChartEditScreen(chart)
      } label: {
        HStack {
          Text(chart.tracker!.tracker!.title!) // TODO: remove tracker name
          Spacer()
          Text(chart.kind.stringValue)
            .foregroundColor(.gray)
        }
        .swipeActions {
          Button("Delete") {
            withAnimation {
              viewContext.delete(chart)
              try! viewContext.save()
            }
          }
        }
      }
    }
  }
}
