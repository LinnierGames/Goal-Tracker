//
//  FeelingSleepyScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 3/13/22.
//

import SwiftUI

struct FeelingSleepyScreen: View {
  @Environment(\.managedObjectContext) private var viewContext

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Sleep.timestamp, ascending: true)],
    animation: .default)
  private var items: FetchedResults<Sleep>

  var body: some View {
    List {
      ForEach(items) { item in
        NavigationLink {
          Text("Item at \(item.timestamp, formatter: itemFormatter)")
        } label: {
          VStack {
            Text(item.timestamp, formatter: itemFormatter)
            Text(item.activity)
          }
        }
      }
      .onDelete(perform: deleteItems)
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        EditButton()
      }
      ToolbarItem {
        Button(action: addItem) {
          Label("Add Item", systemImage: "plus")
        }
      }
    }
  }

  private func addItem() {
    withAnimation {
      let newItem = Sleep(context: viewContext)
      newItem.timestamp = Date()
      newItem.activity = "Driving"

      do {
        try viewContext.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
      }
    }
  }

  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      offsets.map { items[$0] }.forEach(viewContext.delete)

      do {
        try viewContext.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
      }
    }
  }
}

private let itemFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateStyle = .short
  formatter.timeStyle = .medium
  return formatter
}()
