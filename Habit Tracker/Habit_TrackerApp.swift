//
//  Habit_TrackerApp.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 3/11/22.
//

import SwiftUI

@main
struct Habit_TrackerApp: App {
  let persistenceController = PersistenceController.shared

  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}

import Intents
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
  func registerForPushNotifications() {
    //1
    UNUserNotificationCenter.current()
      //2
      .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
        //3
        print("Permission granted: \(granted)")
        guard granted else { return }
        self.getNotificationSettings()
      }
  }

  func getNotificationSettings() {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      print("Notification settings: \(settings)")

      guard settings.authorizationStatus == .authorized else { return }
      DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
      }
    }
  }

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    registerForPushNotifications()

    INPreferences.requestSiriAuthorization { status in
      switch status {
      case .notDetermined, .restricted, .denied:
        print("no siri")
      case .authorized:
        print("yes siri")
      }
    }

    //  let sleepy = INFeelingSleepyIntent()
    //  sleepy.suggestedInvocationPhrase = "Mark feeling tired"
    //  sleepy.activity = "Use iPhone"
    //
    //  let interaction = INInteraction(intent: sleepy, response: nil)
    //  interaction.donate { error in
    //    if let error = error {
    //      print("failed to donate: \(error.localizedDescription)")
    //    } else {
    //      print("donated!")
    //    }
    //  }

    return true
  }

  func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    print("Device Token: \(token)")
  }

  func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("Failed to register: \(error)")
  }

}
