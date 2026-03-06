//
//  TimeGridRow.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 2/28/26.
//

import CoreData
import SwiftUI

struct TimeGridRow: View {
  let timeLabel: String
  let row: Int
  let cellsPerRow: Int
  let cellDuration: TimeInterval
  let startTime: Date
  let logs: [TaskTrackerLog]
  let selectedCells: Set<String>
  let onCellTap: (_ row: Int, _ column: Int) -> Void
  let onCellLongPress: (_ row: Int, _ column: Int) -> Void
  
  var body: some View {
    HStack(spacing: 4) {
      Text(timeLabel)
        .font(.caption2)
        .frame(maxHeight: .infinity, alignment: .top)
        .frame(width: 30, alignment: .trailing)
        .foregroundStyle(Color.gray)
        .multilineTextAlignment(.trailing)
      
      ForEach(0..<cellsPerRow, id: \.self) { column in
        let cellStartTime = startTime.addingTimeInterval(cellDuration * Double(column))
        let cellEndTime = cellStartTime.addingTimeInterval(cellDuration)
        let overlappingLog = logs.first { log in
          log.startDate < cellEndTime && log.endDate > cellStartTime
        }
        let cellId = "\(row),\(column)"
        
        TimeGridCell(
          taskLog: overlappingLog,
          isSelected: selectedCells.contains(cellId),
          onTap: { onCellTap(row, column) },
          onLongPress: { onCellLongPress(row, column) }
        )
      }
    }
    .frame(height: 40)
  }
}

#if DEBUG
struct TimeGridRow_Previews: PreviewProvider {
  static var previews: some View {
    let container = NSPersistentContainer(name: "Habit_Tracker")
    let context = container.viewContext
    
    let task = TaskTracker(context: context)
    task.name = "Work"
    task.color = "#00BFFF"
    
    let now = Date()
    let log = TaskTrackerLog(context: context)
    log.task = task
    log.startDate = now
    log.endDate = now.addingTimeInterval(30 * 60) // 30 min
    
    return VStack {
      TimeGridRow(
        timeLabel: "Hour 9",
        row: 9,
        cellsPerRow: 4,
        cellDuration: 15 * 60,
        startTime: now,
        logs: [log],
        selectedCells: [],
        onCellTap: { _, _ in },
        onCellLongPress: { _, _ in }
      )
      
      TimeGridRow(
        timeLabel: "Hour 10",
        row: 10,
        cellsPerRow: 4,
        cellDuration: 15 * 60,
        startTime: now.addingTimeInterval(60 * 60),
        logs: [],
        selectedCells: ["10,1"],
        onCellTap: { _, _ in },
        onCellLongPress: { _, _ in }
      )
    }
    .padding()
    .previewLayout(.sizeThatFits)
  }
}
#endif
