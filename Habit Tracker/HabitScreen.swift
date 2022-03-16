//
//  ContentView.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 3/11/22.
//

import SwiftUI
import CoreData

struct DataCell<Label: View>: View {
  let label: Label

  @State var toggle = false

  var body: some View {
    label
    Toggle(isOn: $toggle) {
      Text("Include in Export")
    }
  }
}

struct ContentView: View {
  @StateObject var viewModel = HabitViewModel()

  var body: some View {
    NavigationView {
      List {
        Section("Data Collected") {
          // TODO: Support UI building via CollectedData
//          ForEach(viewModel.collectedData, id: \.title) { data in
//            DataCell(
//              label: NavigationLink(data.title, destination: CollectedDataScreen(data: data))
//            )
//          }
          DataCell(label: NavigationLink(
            "Sleep",
            destination: CollectedDataScreen(
              items: FetchRequest<FeelingSleepy>(
                sortDescriptors: [NSSortDescriptor(keyPath: \FeelingSleepy.timestamp, ascending: true)],
                animation: .default
              ),
              row: { item in
                VStack {
                  Text(item.timestamp, format: .dateTime)
                  Text(item.activity)
                }
              },
              detailedScreen: { item in
                Text("Item at \(item.timestamp)")
              },
              addNewDataScreen: {
                Text("new stuff!")
              }
            )
          ))
          DataCell(label: NavigationLink("Shower", destination: Text("Shower stuff")))
        }
        Section("Actions") {
          makeHealthKitAction()
        }
        Section("Other CSV files") {
          makeFilesPicker()
        }
        Button("Export") {
          viewModel.export()
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

  @ViewBuilder
  private func makeFilesPicker() -> some View {
    FilePicker(types: [.commaSeparatedText], allowMultiple: true) { urls in
      viewModel.stageFiles(urls: urls)
    } label: {
      HStack {
          Image(systemName: "doc.on.doc")
          Text("Pick Files")
      }
    }
    if !viewModel.stagedURLs.isEmpty {
      ForEach(viewModel.stagedURLs, id: \.self) { url in
        Text(url.lastPathComponent)
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
