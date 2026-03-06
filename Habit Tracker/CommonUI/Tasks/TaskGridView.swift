//
//  TaskGridView.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 2/28/26.
//

import CoreData
import SwiftUI

struct TaskGridView: View {
  let date: Date
  let taskLogs: [TaskTrackerLog]
  let gridMode: GridMode
  let selectedCells: Set<String>
  let onCellTap: (_ row: Int, _ column: Int) -> Void
  let onRangeSelect: (_ startCellId: String, _ endCellId: String) -> Void
  
  @State private var startCellId: String? = nil
  @State private var isDragging = false
  
  var body: some View {
    HStack(spacing: 0) {
      ScrollView(.vertical, showsIndicators: true) {
        VStack(spacing: 4) {
          ForEach(0..<gridMode.rowCount, id: \.self) { row in
            let rowLabel = Date.rowLabel(
              for: row,
              in: gridMode,
              referenceDate: date
            )
            let rowStartTime = computeRowStartTime(for: row)
            let rowLogs = taskLogs.filter { log in
              let cellEndTime = rowStartTime.addingTimeInterval(gridMode.cellDuration * Double(gridMode.cellsPerRow))
              return log.startDate < cellEndTime && log.endDate > rowStartTime
            }
            
            TimeGridRow(
              timeLabel: rowLabel,
              row: row,
              cellsPerRow: gridMode.cellsPerRow,
              cellDuration: gridMode.cellDuration,
              startTime: rowStartTime,
              logs: rowLogs,
              selectedCells: selectedCells,
              onCellTap: { r, c in
                let cellId = "\(r),\(c)"
                if isDragging && startCellId != nil && startCellId != cellId {
                  // Range selection
                  onRangeSelect(startCellId!, cellId)
                  isDragging = false
                  startCellId = nil
                } else {
                  // Single selection
                  onCellTap(r, c)
                }
              },
              onCellLongPress: { r, c in
                let cellId = "\(r),\(c)"
                startCellId = cellId
                
                if !isDragging {
                    // Single selection
                    onCellTap(r, c)
                }
                
                isDragging = true
              }
            )
          }
        }
        .padding(.trailing)
      }
    }
  }
  
  private func computeRowStartTime(for row: Int) -> Date {
    let calendar = Calendar.current
    let gridStartDate: Date
    
    switch gridMode {
    case .fifteenMinDaily:
      gridStartDate = date.startOfDay()
    case .hourly:
      gridStartDate = date.startOfDay()
    case .weekly:
      gridStartDate = date.startOfWeek
    case .monthly:
      gridStartDate = date.startOfMonth()
    }
    
    let rowDuration = TimeInterval(gridMode.cellsPerRow) * gridMode.cellDuration
    let offsetSeconds = Int(rowDuration * Double(row))
    
    return calendar.date(
      byAdding: .second,
      value: offsetSeconds,
      to: gridStartDate
    ) ?? gridStartDate
  }
}

#if DEBUG
struct TaskGridView_Previews: PreviewProvider {
  static var previews: some View {
    let container = NSPersistentContainer(name: "Habit_Tracker")
    let context = container.viewContext
    
    let tasks = TaskTracker.previewTasks(in: context)
    let logs = tasks.prefix(3).flatMap { task in
      (0..<3).map { _ in TaskTrackerLog.previewLog(task: task, in: context, for: Date()) }
    }
    
    return Group {
      TaskGridView(
        date: Date(),
        taskLogs: logs,
        gridMode: .fifteenMinDaily,
        selectedCells: ["0,1"],
        onCellTap: { _, _ in },
        onRangeSelect: { _, _ in }
      )
      .previewDisplayName("15-min Daily")
      
      TaskGridView(
        date: Date(),
        taskLogs: logs,
        gridMode: .hourly,
        selectedCells: [],
        onCellTap: { _, _ in },
        onRangeSelect: { _, _ in }
      )
      .previewDisplayName("Hourly")
      
      TaskGridView(
        date: Date(),
        taskLogs: logs,
        gridMode: .weekly,
        selectedCells: ["0,3"],
        onCellTap: { _, _ in },
        onRangeSelect: { _, _ in }
      )
      .previewDisplayName("Weekly")
    }
    .previewLayout(.sizeThatFits)
    .frame(height: 300)
  }
}
#endif
