//
//  TimeGridCell.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 2/28/26.
//

import CoreData
import SwiftUI

struct TimeGridCell: View {
    let taskLog: TaskTrackerLog?
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            // Background color based on log
            if let taskLog {
                Color(hex: taskLog.task.color)
            } else {
                Color(.systemGray5)
            }
            
            // Selection indicator
            if isSelected {
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color(.label), lineWidth: 2)
                    .padding(1)
            }
        }
        .cornerRadius(4)
        .aspectRatio(1, contentMode: .fit)
        .onTapGesture(perform: onTap)
    }
}

#if DEBUG
struct TimeGridCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            // Empty cell
//            TimeGridCell(
//                taskLog: nil,
//                isSelected: false,
//                onTap: {}
//            )
//            .frame(height: 40)
//            
//            // Logged cell
//            let container = NSPersistentContainer(name: "Habit_Tracker")
//            let context = container.viewContext
//            let task = Task(context: context)
//            task.name = "Chill"
//            task.color = "#FF1493"
//            
//            let log = TaskTrackerLog(context: context)
//            log.task = task
//            log.startDate = Date()
//            log.endDate = Date().addingTimeInterval(900)
//            
//            TimeGridCell(
//                taskLog: log,
//                isSelected: false,
//                onTap: {}
//            )
//            .frame(height: 40)
//            
//            // Selected cell
//            TimeGridCell(
//                taskLog: log,
//                isSelected: true,
//                onTap: {}
//            )
//            .frame(height: 40)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
