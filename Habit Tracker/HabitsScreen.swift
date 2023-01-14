//
//  HabbitsScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 1/14/23.
//

import SwiftUI

struct HabitsScreen: View {
  var body: some View {
    Text("Habits")
  }
}

struct ImportDataScreen: View {
  @State private var stagedURLs = [URL]()

  var body: some View {
    VStack {
      List {
        Section("Habits") {
          FilePicker(types: [.commaSeparatedText], allowMultiple: false) { urls in
            stageFiles(urls: urls)
          } label: {
            HStack {
                Image(systemName: "doc.on.doc")
                Text("Pick File")
            }
          }
          if !stagedURLs.isEmpty {
            ForEach(stagedURLs, id: \.self) { url in
              Text(url.lastPathComponent)
            }
            .onDelete { index in
              stagedURLs.remove(at: index.first!)
            }
          }
        }

        Section("Sleep") {

        }

        Section("Blocks") {

        }

        Section("Calory") {

        }
      }

      ButtonFill("Import", fill: .blue) {
        importHabits(url: stagedURLs[0])
      }
      .disabled(stagedURLs.isEmpty)
    }
  }

  private func stageFiles(urls: [URL]) {
    stagedURLs = urls
  }

  private func importHabits(url: URL) {
    guard
      let data = try? Data(contentsOf: url),
      let content = try? String(data: data, encoding: .utf8)
    else {
      return
    }

    let parsedCSV: [String] = content.components(
        separatedBy: "\n"
    ).map{ $0.components(separatedBy: ",")[0] } // fix this

    print(parsedCSV)
  }
}

struct AnalyticsScreen: View {
  var body: some View {
    Text("Analytics")
  }
}
