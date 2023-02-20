//
//  ScreenTimeAPI.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 2/18/23.
//

import DeviceActivity
import ScreenTime

class ScreenTimeService {
  
}

import HealthKit

class HealthKitService {

  let store = HKHealthStore()

  var isHealthDataAvailable: Bool {
    HKHealthStore.isHealthDataAvailable()
  }

  func requestAccess(completion: @escaping () -> Void) {
    guard isHealthDataAvailable else { return }

    let allTypes = Set([
//      HKObjectType.workoutType(),
//      HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
//      HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
//      HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
//      HKObjectType.quantityType(forIdentifier: .heartRate)!,
//      HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.mindfulSession)!,
      HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
    ])

    store.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
      if !success {
        // Handle the error here.
        print("no good", error!)
        return
      }

      print("requestAuthorization good!")
      completion()
    }
  }

  func requestAccess() async {
    await withCheckedContinuation { continuation in
      requestAccess {
        continuation.resume()
      }
    }
  }
}
