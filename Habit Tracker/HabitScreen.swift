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
          DataCell(label: NavigationLink("Sleep", destination: FeelingSleepyScreen()))
          DataCell(label: NavigationLink("Shower", destination: Text("Shower stuff")))
        }
        Section("Actions") {
          makeHealthKitAction()
        }
        Section("Other CSV files") {
          makeFilesPicker()
        }
        Button("Export") {

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

import SwiftUI
import UniformTypeIdentifiers

public struct FilePicker<LabelView: View>: View {

    public typealias PickedURLsCompletionHandler = (_ urls: [URL]) -> Void
    public typealias LabelViewContent = () -> LabelView

    @State private var isPresented: Bool = false

    public let types: [UTType]
    public let allowMultiple: Bool
    public let pickedCompletionHandler: PickedURLsCompletionHandler
    public let labelViewContent: LabelViewContent

    public init(types: [UTType], allowMultiple: Bool, onPicked completionHandler: @escaping PickedURLsCompletionHandler, @ViewBuilder label labelViewContent: @escaping LabelViewContent) {
        self.types = types
        self.allowMultiple = allowMultiple
        self.pickedCompletionHandler = completionHandler
        self.labelViewContent = labelViewContent
    }

    public init(types: [UTType], allowMultiple: Bool, title: String, onPicked completionHandler: @escaping PickedURLsCompletionHandler) where LabelView == Text {
        self.init(types: types, allowMultiple: allowMultiple, onPicked: completionHandler) { Text(title) }
    }

    #if os(iOS)

    public var body: some View {
        Button(
            action: {
                if !isPresented { isPresented = true }
            },
            label: {
                labelViewContent()
            }
        )
        .disabled(isPresented)
        .sheet(isPresented: $isPresented) {
            FilePickerUIRepresentable(types: types, allowMultiple: allowMultiple, onPicked: pickedCompletionHandler)
        }
    }

    #endif

    #if os(macOS)
    public var body: some View {
        Button(
            action: {
                if !isPresented { isPresented = true }
            },
            label: {
                labelViewContent()
            }
        )
        .disabled(isPresented)
        .onChange(of: isPresented, perform: { presented in
            // binding changed from false to true
            if presented == true {
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = allowMultiple
                panel.canChooseDirectories = false
                panel.canChooseFiles = true
                panel.allowedFileTypes = types.map { $0.identifier }
                panel.begin { reponse in
                    if reponse == .OK {
                        pickedCompletionHandler(panel.urls)
                    }
                    // reset the isPresented variable to false
                    isPresented = false
               }
            }
        })
    }
    #endif

}


import SwiftUI
import UniformTypeIdentifiers

#if os(iOS)

public struct FilePickerUIRepresentable: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIDocumentPickerViewController
    public typealias PickedURLsCompletionHandler = (_ urls: [URL]) -> Void

    @Environment(\.presentationMode) var presentationMode

    public let types: [UTType]
    public let allowMultiple: Bool
    public let pickedCompletionHandler: PickedURLsCompletionHandler

    public init(types: [UTType], allowMultiple: Bool, onPicked completionHandler: @escaping PickedURLsCompletionHandler) {
        self.types = types
        self.allowMultiple = allowMultiple
        self.pickedCompletionHandler = completionHandler
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = allowMultiple
        return picker
    }

    public func updateUIViewController(_ controller: UIDocumentPickerViewController, context: Context) {}

    public class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: FilePickerUIRepresentable

        init(parent: FilePickerUIRepresentable) {
            self.parent = parent
        }

        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.pickedCompletionHandler(urls)
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#endif
