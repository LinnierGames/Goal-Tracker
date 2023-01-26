//
//  CollcetedData.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 3/16/22.
//

import CoreData

struct CollectedData<Data: NSManagedObject, ViewBuilder: View, DetailView: View, AddNewDataScreen: View> {
  let title: String
  let fields: [String]
  let fetchRequest: FetchRequest<Data>
  let viewBuilder: (Data) -> ViewBuilder
  let detailScreen: (Data) -> DetailView
  let addNewDataScreen: AddNewDataScreen
}

struct AddFeelingSleepyData: View {
  var body: some View {
    Text("New stuff!")
  }
}
let collectedData = [
  CollectedData(
    title: "Feeling Sleepy",
    fields: ["timestamp", "activity"],
    fetchRequest: FetchRequest<Sleep>(
      sortDescriptors: [NSSortDescriptor(keyPath: \Sleep.timestamp, ascending: true)],
      animation: .default
    ),
    viewBuilder: { sleep in
      VStack {
        Text(sleep.timestamp, format: .dateTime)
        Text(sleep.activity)
      }
    },
    detailScreen: { sleep in
      Text(sleep.timestamp, format: .dateTime)
    },
    addNewDataScreen: AddFeelingSleepyData()
  ),
  CollectedData(
    title: "Feeling Sleepy",
    fields: ["timestamp", "activity"],
    fetchRequest: FetchRequest<NSManagedObject>(
      fetchRequest: NSFetchRequest(entityName: "HI"), animation: .default
    ),
    viewBuilder: { sleep in
      VStack {
        Text("HI")
      }
    },
    detailScreen: { sleep in
      Text("H")
    },
    addNewDataScreen: AddFeelingSleepyData()
  ),
] as [Any]

collectedData.map { data in
//      CSVContent(
//      )

  let fetchRequest = data.fetchRequest
  let headers = data.fields
  let rowBuilder = { row in "\(row.timestamp),\(row.activity)" }
}

struct CollectedDataScreen<
  Data: NSManagedObject & Identifiable,
  ViewBuilder: View,
  DetailView: View,
  AddNewDataScreen: View
>: View {
  private let dataSource: CollectedData<Data, ViewBuilder, DetailView, AddNewDataScreen>

  @Environment(\.managedObjectContext) private var viewContext

  @FetchRequest private var items: FetchedResults<Data>
  @State private var isShowingAddScreen = false

  init(data: CollectedData<Data, ViewBuilder, DetailView, AddNewDataScreen>) {
    self.dataSource = data
    _items = data.fetchRequest
  }

  var body: some View {
    List {
      ForEach(items) { item in
        NavigationLink {
          dataSource.detailScreen(item)
        } label: {
          dataSource.viewBuilder(item)
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
      dataSource.addNewDataScreen
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
