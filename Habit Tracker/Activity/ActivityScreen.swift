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
    @State private var selectedCell: (row: Int, column: Int)? = nil
    @State private var gridMode: GridMode = .fifteenMinDaily
    @State private var showAddTaskSheet = false
    @State private var showDatePicker = false
    
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
        selectedCell != nil ? gridMode.cellDescription : ""
    }
    
    var body: some View {
      NavigationStack {
        VStack(spacing: 0) {
          // MARK: - Header
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
                selectedCell = nil
              }
            }
            
            Button("Today") {
              selectedDate = Date()
              selectedCell = nil
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
              AddTaskSheet(isPresented: $showAddTaskSheet)
            }
          }
          .padding()
          .background(Color(.systemBackground))
          .border(Color(.systemGray5), width: 1)
          
          // MARK: - Main Content
          HStack(spacing: 0) {
            // Grid
            TaskGridView(
              date: selectedDate,
              taskLogs: taskLogsForSelectedDate,
              gridMode: gridMode,
              selectedCell: selectedCell,
              onCellTap: { row, column in
                selectedCell = (row, column)
              }
            )
            
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
                      level: 0
                    )
                    .padding(8)
                  }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
              }
              .frame(width: 120)
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
          
          // MARK: - Footer
          HStack(spacing: 12) {
            if selectedCell != nil {
              Text("\(selectedCellDurationDescription) selected")
                .font(.caption)
                .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button("De-select") {
              selectedCell = nil
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
        .navigationTitle("Activity")
      }
    }
    
    private func assignTaskToCell(_ task: TaskTracker) {
        guard let (row, column) = selectedCell else { return }
        
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
        
        do {
            try moc.save()
            selectedCell = nil  // Clear selection after logging
        } catch {
            print("Error saving task log: \(error.localizedDescription)")
        }
    }
    
    private func eraseSelectedLog() {
        guard let (row, column) = selectedCell else { return }
        
        let (startDate, endDate) = Date.dateRange(
            for: row,
            column: column,
            in: gridMode,
            referenceDate: selectedDate
        )
        
        // Find overlapping logs
        let overlappingLogs = taskLogsForSelectedDate.filter { log in
            log.startDate < endDate && log.endDate > startDate
        }
        
        overlappingLogs.forEach { moc.delete($0) }
        
        do {
            try moc.save()
            selectedCell = nil
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

