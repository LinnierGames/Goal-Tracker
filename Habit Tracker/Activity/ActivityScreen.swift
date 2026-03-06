//
//  ActivityScreen.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 2/28/26.
//

import CoreData
import SwiftUI

struct ActivityScreen: View {
  @Environment(\.managedObjectContext) var moc
  
  @FetchRequest(
    entity: TaskTracker.entity(),
    sortDescriptors: [NSSortDescriptor(keyPath: \TaskTracker.order, ascending: true)],
    predicate: NSPredicate(format: "parentTask == nil")
  ) var rootTasks: FetchedResults<TaskTracker>
  
  @FetchRequest(
    entity: TaskTrackerLog.entity(),
    sortDescriptors: [NSSortDescriptor(keyPath: \TaskTrackerLog.startDate, ascending: false)]
  ) var allTaskLogs: FetchedResults<TaskTrackerLog>
  
  @State private var selectedDate = Date()
  @State private var selectedCells: Set<String> = []
  @State private var gridMode: GridMode = .fifteenMinDaily
  @State private var showAddTaskSheet = false
  @State private var showDatePicker = false
  @State private var isEditing: Bool = false
  @State private var isSelectionMode: Bool = false
  
  var taskLogsForSelectedDate: [TaskTrackerLog] {
    let calendar = Calendar.current
    let dayStart: Date
    let dayEnd: Date
    
    switch gridMode {
    case .fifteenMinDaily, .hourly:
      dayStart = selectedDate.startOfDay()
      dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
      
    case .weekly:
      dayStart = selectedDate.startOfWeek
      dayEnd = calendar.date(byAdding: .day, value: 7, to: dayStart) ?? dayStart
      
    case .monthly:
      dayStart = selectedDate.startOfMonth()
      dayEnd = calendar.date(byAdding: .month, value: 1, to: dayStart) ?? dayStart
    }
    
    return allTaskLogs.filter { log in
      log.startDate < dayEnd && log.endDate > dayStart
    }
  }
  
  var selectedCellDurationDescription: String {
    selectedCells.isEmpty ? "" : "\(selectedCells.count) blocks"
  }
  
  var header: some View {
    HStack(spacing: 8) {
      Button(action: { showDatePicker = true }) {
        Image(systemName: "calendar")
          .font(.subheadline)
      }
      .popover(isPresented: $showDatePicker) {
        DatePicker(
          "Select Date",
          selection: $selectedDate,
          displayedComponents: .date
        )
        .datePickerStyle(.graphical)
        .padding()
        .onDisappear {
          selectedCells = []
        }
      }
      
      Button("Today") {
        selectedDate = Date()
        selectedCells = []
      }
      .font(.caption)
      
      Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
        .font(.subheadline)
        .fontWeight(.semibold)
      
      Spacer()
      
      Picker("Grid Mode", selection: $gridMode) {
        Text("15min").tag(GridMode.fifteenMinDaily)
        Text("Hour").tag(GridMode.hourly)
        Text("Week").tag(GridMode.weekly)
        Text("Month").tag(GridMode.monthly)
      }
      .pickerStyle(.segmented)
      .font(.caption)
      
      Button(action: { showAddTaskSheet = true }) {
        Image(systemName: "plus.circle.fill")
          .font(.subheadline)
      }
      .sheet(isPresented: $showAddTaskSheet) {
        AddTaskSheet(parentTask: nil, isPresented: $showAddTaskSheet)
      }
    }
    .padding()
    .background(Color(.systemBackground))
    .border(Color(.systemGray5), width: 1)
  }
  
  var content: some View {
    HStack(spacing: 0) {
      // Grid
      TaskGridView(
        date: selectedDate,
        taskLogs: taskLogsForSelectedDate,
        gridMode: gridMode,
        selectedCells: selectedCells,
        onCellTap: { row, column in
          let cellId = "\(row),\(column)"
          if isSelectionMode {
            // In selection mode, toggle cell in set
            if selectedCells.contains(cellId) {
              selectedCells.remove(cellId)
            } else {
              selectedCells.insert(cellId)
            }
          } else {
            // Single selection mode
            if selectedCells.contains(cellId) {
              selectedCells.remove(cellId)
            } else {
              selectedCells = [cellId]
            }
          }
        },
        onRangeSelect: { startCellId, endCellId in
          isSelectionMode = true
          let startComponents = startCellId.split(separator: ",").compactMap { Int($0) }
          let endComponents = endCellId.split(separator: ",").compactMap { Int($0) }
          
          guard startComponents.count == 2, endComponents.count == 2 else { return }
          let (startRow, startCol) = (startComponents[0], startComponents[1])
          let (endRow, endCol) = (endComponents[0], endComponents[1])
          
          // Convert to chronological (linear) indices
          let cellsPerRow = gridMode.cellsPerRow
          let startIndex = startRow * cellsPerRow + startCol
          let endIndex = endRow * cellsPerRow + endCol
          
          let minIndex = min(startIndex, endIndex)
          let maxIndex = max(startIndex, endIndex)
          
          // Select all cells in chronological order
          for index in minIndex...maxIndex {
            let row = index / cellsPerRow
            let col = index % cellsPerRow
            selectedCells.insert("\(row),\(col)")
          }
        }
      )
      .frame(width: 200)
      
      // Task Sidebar
      VStack(spacing: 0) {
        ScrollView {
          VStack(alignment: .leading, spacing: 4) {
            if rootTasks.isEmpty {
              Text("No tasks yet")
                .font(.caption)
                .foregroundColor(.gray)
                .padding()
            } else {
              TaskTreeView(
                rootTasks: Array(rootTasks),
                onTaskTap: { task in
                  assignTaskToCell(task)
                },
                level: 0, isEditing: isEditing,
              )
              .padding(8)
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        .border(Color(.systemGray5), width: 1)
        
        Button(action: { showAddTaskSheet = true }) {
          Text("More Types")
            .font(.caption2)
            .frame(maxWidth: .infinity)
        }
        .padding(8)
        .border(Color(.systemGray5), width: 1)
      }
    }
  }
  
  var footer: some View {
    HStack(spacing: 12) {
      Text("\(selectedCellDurationDescription) selected")
        .font(.caption)
        .foregroundColor(.gray)
      
      Spacer()
      
      Button("De-select") {
        selectedCells = []
        isSelectionMode = false
      }
      .font(.caption)
      .buttonStyle(.bordered)
      
      Button("Erase") {
        eraseSelectedLog()
      }
      .font(.caption)
      .buttonStyle(.bordered)
      .tint(.red)
    }
    .padding()
    .background(Color(.systemGray6))
  }
  
  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        header
        content
        
        if !selectedCells.isEmpty {
          footer
            .animation(.spring, value: selectedCells.isEmpty)
            .transition(.move(edge: .bottom))
        }
      }
      .navigationTitle("Activity")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button(isEditing ? "Done" : "Edit") {
            isEditing.toggle()
          }
        }
      }
    }
  }
  
  private func assignTaskToCell(_ task: TaskTracker) {
    for cellId in selectedCells {
      let components = cellId.split(separator: ",").compactMap { Int($0) }
      guard components.count == 2 else { continue }
      let (row, column) = (components[0], components[1])
      
      let (startDate, endDate) = Date.dateRange(
        for: row,
        column: column,
        in: gridMode,
        referenceDate: selectedDate
      )
      
      let newLog = TaskTrackerLog(context: moc)
      newLog.task = task
      newLog.startDate = startDate
      newLog.endDate = endDate
      newLog.createdAt = Date()
      newLog.updatedAt = Date()
    }
    
    do {
      try moc.save()
      selectedCells = []
      isSelectionMode = false
    } catch {
      print("Error saving task log: \(error.localizedDescription)")
    }
  }
  
  private func eraseSelectedLog() {
    var logsToDelete: [TaskTrackerLog] = []
    
    for cellId in selectedCells {
      let components = cellId.split(separator: ",").compactMap { Int($0) }
      guard components.count == 2 else { continue }
      let (row, column) = (components[0], components[1])
      
      let (startDate, endDate) = Date.dateRange(
        for: row,
        column: column,
        in: gridMode,
        referenceDate: selectedDate
      )
      
      let overlappingLogs = taskLogsForSelectedDate.filter { log in
        log.startDate < endDate && log.endDate > startDate
      }
      logsToDelete.append(contentsOf: overlappingLogs)
    }
    
    logsToDelete.forEach { moc.delete($0) }
    
    do {
      try moc.save()
      selectedCells = []
      isSelectionMode = false
    } catch {
      print("Error deleting task log: \(error.localizedDescription)")
    }
  }
}

#if DEBUG
struct ActivityScreen_Previews: PreviewProvider {
  static var previews: some View {
    let container = NSPersistentContainer(name: "Habit_Tracker")
    let context = container.viewContext
    
    let tasks = TaskTracker.previewTasks(in: context)
    let logs = tasks.prefix(3).flatMap { task in
      (0..<2).map { _ in TaskTrackerLog.previewLog(task: task, in: context, for: Date()) }
    }
    
    try? context.save()
    
    return NavigationView {
      ActivityScreen()
        .environment(\.managedObjectContext, context)
    }
    .preferredColorScheme(.light)
  }
}
#endif

