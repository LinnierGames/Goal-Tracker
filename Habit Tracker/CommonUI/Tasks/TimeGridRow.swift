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
    let cellsPerRow: Int
    let cellDuration: TimeInterval
    let startTime: Date
    let logs: [TaskTrackerLog]
    let selectedCell: Int?
    let onCellTap: (Int) -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            // Time label
            Text(timeLabel)
                .font(.caption2)
                .frame(width: 40)
                .lineLimit(1)
            
            // Cells
            ForEach(0..<cellsPerRow, id: \.self) { cellIndex in
                let cellStartTime = startTime.addingTimeInterval(cellDuration * Double(cellIndex))
                let cellEndTime = cellStartTime.addingTimeInterval(cellDuration)
                
                // Find log that overlaps this cell
                let overlappingLog = logs.first { log in
                    log.startDate < cellEndTime && log.endDate > cellStartTime
                }
                
                TimeGridCell(
                    taskLog: overlappingLog,
                    isSelected: selectedCell == cellIndex,
                    onTap: {
                        onCellTap(cellIndex)
                    }
                )
            }
            
            Spacer()
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
                cellsPerRow: 4,
                cellDuration: 15 * 60,
                startTime: now,
                logs: [log],
                selectedCell: nil,
                onCellTap: { _ in }
            )
            
            TimeGridRow(
                timeLabel: "Hour 10",
                cellsPerRow: 4,
                cellDuration: 15 * 60,
                startTime: now.addingTimeInterval(60 * 60),
                logs: [],
                selectedCell: 1,
                onCellTap: { _ in }
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
