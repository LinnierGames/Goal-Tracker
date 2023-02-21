//
//  ImportScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 2/20/23.
//

import SwiftUI

struct ImportScreen: View {

  @State private var updateUI = false

  @Environment(\.managedObjectContext)
  private var viewContext

  private let healthKitService = HealthKitService.shared

  var body: some View {
    NavigationView {
      List {
        healthKitSection()
        deviceActivitySection()
      }
      .navigationTitle("Import")
    }
  }

  // MARK: HealthKit

  @ViewBuilder
  private func healthKitSection() -> some View {

    Section("HealthKit") {
      Text("Create trackers to sync data from HealthKit")

      if !healthKitService.isHealthDataAvailable {
        Button("Request Access") {
          healthKitService.requestAccess {
            updateUI.toggle()
          }
        }
      }
    }

    if healthKitService.isHealthDataAvailable {
      healthKitSleepSection()
    }

    Section {
      Text("Workouts includes workout type, duration, and calories")
      Text("Not supported, yet")
    }

    Section {
      Text("Vitals includes heart rate, oxygen levels, and more")
      Text("Not supported, yet")
    }
  }

  @ViewBuilder
  private func healthKitSleepSection() -> some View {
    Section {
      Text("Sleep data includes in bed time intervals")
      if healthKitService.isSleepGranted {
        if let sleepTracker: Tracker = healthKitTracker(source: .sleepInBedIntervals) {
          NavigationSheetLink {
            TrackerDetailScreen(sleepTracker)
          } label: {
            Label(sleepTracker.title!, systemImage: "text.book.closed")
          }
        } else {
          Button(action: {
            _ = Tracker.makeHealthKitTracker(dataSource: .sleepInBedIntervals, context: viewContext)
            try! viewContext.save()
            updateUI.toggle()
          }, title: "Create Tracker", systemImage: "text.book.closed")
        }
      } else {
        Text("Sleep is not granted")
        Button("Request Access") {
          healthKitService.requestAccess {
            updateUI.toggle()
          }
        }
      }
    }
  }

  private func healthKitTracker(source: TrackerHealthKitDataSource) -> Tracker? {
    let trackerForSource = Tracker.fetchRequest()
    trackerForSource.predicate = NSPredicate(
      format: "%K == %@",
      #keyPath(Tracker.externalDataSource), source.stringValue
    )

    return try! viewContext.fetch(trackerForSource).first
  }

  // MARK: Device Activity

  @ViewBuilder
  private func deviceActivitySection() -> some View {

    Section("Device Activity") {
      Text("Create trackers to sync data from Screen Time")
    }

    Section {
      Text("Workouts includes workout type, duration, and calories")
      Text("Not supported, yet")
    }
  }
}
