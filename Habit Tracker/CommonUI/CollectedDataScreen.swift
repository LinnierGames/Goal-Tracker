//
//  CollectedDataScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 3/13/22.
//

import CoreData
import SwiftUI

struct CollectedDataScreen<
  Data: NSManagedObject & Identifiable,
  DetailedScreen: View,
  Row: View,
  AddNewDataScreen: View
>: View {
  @Environment(\.managedObjectContext) private var viewContext

  private let row: (Data) -> Row
  private let detailedScreen: (Data) -> DetailedScreen
  private let addNewDataScreen: () -> AddNewDataScreen

  @FetchRequest
  private var items: FetchedResults<Data>
  @State private var isShowingAddScreen = false

  init(
    items: FetchRequest<Data>,
    @ViewBuilder row: @escaping (Data) -> Row,
    @ViewBuilder detailedScreen: @escaping (Data) -> DetailedScreen,
    @ViewBuilder addNewDataScreen: @escaping () -> AddNewDataScreen
  ) {
    _items = items
    self.row = row
    self.detailedScreen = detailedScreen
    self.addNewDataScreen = addNewDataScreen
  }

  var body: some View {
    List {
      ForEach(items) { item in
        NavigationLink {
          detailedScreen(item)
        } label: {
          row(item)
        }
      }
      .onDelete(perform: deleteItems)
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        EditButton()
      }
      ToolbarItem {
        Button(action: { isShowingAddScreen = true }) {
          Label("Add Item", systemImage: "plus")
        }
      }
    }
    .sheet(isPresented: $isShowingAddScreen) {
      addNewDataScreen()
    }
  }

  private func addItem() {
    withAnimation {
      let newItem = FeelingSleepy(context: viewContext)
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
