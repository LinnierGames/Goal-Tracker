//
//  OldApp.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 2/18/23.
//

import Foundation

struct OldApp: View {
  let persistenceController: PersistenceController

  var body: some View {
    TabView {
      DataCollectorScreen()
        .tabItem {
          Label("Data", systemImage: "antenna.radiowaves.left.and.right")
        }
      ReportsScreen()
        .tabItem {
          Label("Reports", systemImage: "newspaper")
        }
    }
    .environment(\.managedObjectContext, persistenceController.container.viewContext)
  }
}
