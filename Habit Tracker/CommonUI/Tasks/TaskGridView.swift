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
    let selectedCell: (row: Int, column: Int)?
    let onCellTap: (_ row: Int, _ column: Int) -> Void
    
    var timeAxisLabels: [String] {
        switch gridMode {
        case .fifteenMinDaily:
            return (0..<24).map { "\($0)" }
        case .hourly:
            return [""]
        case .weekly:
            let weekStart = date.startOfWeek
            let calendar = Calendar.current
            return (0..<7).compactMap { dayOffset in
                let dayDate = calendar.date(byAdding: .day, value: dayOffset, to: weekStart)
                let formatter = DateFormatter()
                formatter.dateFormat = "E"
                return dayDate.map { formatter.string(from: $0) } ?? ""
            }
        case .monthly:
            return (0..<5).map { weekNum in "W\(weekNum + 1)" }
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Left: Time axis labels
//            TimeAxisLabels(labels: timeAxisLabels, mode: gridMode)
            
            // Right: Scrollable grid
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
                            cellsPerRow: gridMode.cellsPerRow,
                            cellDuration: gridMode.cellDuration,
                            startTime: rowStartTime,
                            logs: rowLogs,
                            selectedCell: selectedCell?.row == row ? selectedCell?.column : nil,
                            onCellTap: { column in
                                onCellTap(row, column)
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
                selectedCell: (0, 1),
                onCellTap: { _, _ in }
            )
            .previewDisplayName("15-min Daily")
            
            TaskGridView(
                date: Date(),
                taskLogs: logs,
                gridMode: .hourly,
                selectedCell: nil,
                onCellTap: { _, _ in }
            )
            .previewDisplayName("Hourly")
            
            TaskGridView(
                date: Date(),
                taskLogs: logs,
                gridMode: .weekly,
                selectedCell: (0, 3),
                onCellTap: { _, _ in }
            )
            .previewDisplayName("Weekly")
        }
        .previewLayout(.sizeThatFits)
        .frame(height: 300)
    }
}
#endif
