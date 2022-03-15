//
//  AppDelegate.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 3/15/22.
//

import UIKit
import Intents
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    registerForPushNotifications()
    registerForSiri()

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

  private func registerForSiri() {
    INPreferences.requestSiriAuthorization { status in
      switch status {
      case .notDetermined, .restricted, .denied:
        print("no siri")
      case .authorized:
        print("yes siri")
      @unknown default:
        fatalError()
      }
    }
  }

  private func registerForPushNotifications() {
    UNUserNotificationCenter.current()
      .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
        print("Permission granted: \(granted)")
        guard granted else { return }
        self.getNotificationSettings()
      }
  }

  private func getNotificationSettings() {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      print("Notification settings: \(settings)")

      guard settings.authorizationStatus == .authorized else { return }
      DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
      }
    }
  }
}
