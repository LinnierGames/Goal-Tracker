//
//  ContentView.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 3/11/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
  @StateObject var viewModel = HabitViewModel()

  var body: some View {
    NavigationView {
      List {
        Section("Data Collected") {
          NavigationLink("Sleep", destination: FeelingSleepyScreen())
          NavigationLink("Shower", destination: Text("Shower stuff"))
        }
        Section("Actions") {
          makeHealthKitAction()
          Button("Select Files") {

          }
          Button("Export") {

          }
        }
      }

      .navigationTitle("Habits")
    }
  }

  @ViewBuilder
  private func makeHealthKitAction() -> some View {
    if viewModel.isHealthKitGranted {
      if viewModel.inBedTimes.isEmpty {
        Button("Query HealthKit Data") {
          viewModel.fetchHealthKit()
        }
      } else {
        NavigationLink(
          "Query HealthKit Data: \(viewModel.inBedTimes.count) rows",
          destination: SleepSamplesScreen(samples: viewModel.inBedTimes)
        )
      }
    } else {
      Button("Request HealthKit") {
        viewModel.requestHealthKitPremission()
      }
    }
  }
}

struct SleepSamplesScreen: View {
  let samples: [SleepSample]

  var body: some View {
    List(samples, id: \.start) { sample in
      Text(sample.start, format: .dateTime)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
