//
//  ContentView.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 3/11/22.
//

import SwiftUI
import CoreData

struct DataCollectorScreen: View {
  @StateObject var viewModel: HabitViewModel

  init() {
    _viewModel = StateObject(wrappedValue: HabitViewModel())
  }

  @AppStorage("HOST_STRING") private var hostString = "http://10.0.0.166:3000"

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
          NavigationLink(
            "Feeling Sleepy",
            destination: CollectedDataScreen(
              items: FetchRequest<FeelingSleepy>(
                sortDescriptors: [NSSortDescriptor(keyPath: \FeelingSleepy.timestamp, ascending: false)],
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
          )
          NavigationLink(
            "Shower",
            destination: CollectedDataScreen(
              items: FetchRequest<ShowerTimestamp>(
                sortDescriptors: [NSSortDescriptor(keyPath: \FeelingSleepy.timestamp, ascending: false)],
                animation: .default
              ),
              row: { item in
                VStack {
                  Text(item.timestamp!, format: .dateTime)
                  Text(item.products!.joined(separator: ", "))
                }
              },
              detailedScreen: { item in
                Text("Item at \(item.timestamp!)")
              },
              addNewDataScreen: {
                Text("new stuff!")
              }
            )
          )
        }
        Section("Actions") {
          makeHealthKitAction()
        }
        Section("Imported Files") {
          ForEach(viewModel.importedFiles, id: \.self) { url in
            Text(url.lastPathComponent)
          }.onDelete { index in
            let index = index.first!
            viewModel.deleteImportedFile(at: index)
          }
        }
        Section("Other CSV files") {
          makeFilesPicker()
        }
        Button("Export") {
          viewModel.export(to: hostString)
        }
        TextField("Host", text: $hostString)
      }
      .disabled(viewModel.isLoading)
      .loadingIndicator(isShowing: viewModel.isLoading)

      .alert(content: $viewModel.alert)

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
      .onDelete { index in
        viewModel.stagedURLs.remove(at: index.first!)
      }
    }
  }
}

struct SleepSamplesScreen: View {
  let samples: [SleepSample]

  var body: some View {
    List(samples, id: \.start) { sample in
      VStack {
        HStack {
          Text("Start")
          Text(sample.start, format: .dateTime)
        }
        HStack {
          Text("End")
          Text(sample.end, format: .dateTime)
        }
        HStack {
          Text("Duration")
          Text(sample.start..<sample.end, format: .timeDuration)
        }
      }
    }
  }
}

private struct Previews: PreviewProvider {
  static var previews: some View {
    DataCollectorScreen().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
