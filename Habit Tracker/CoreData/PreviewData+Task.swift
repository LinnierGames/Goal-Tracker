//
//  PreviewData+Task.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 2/28/26.
//

import Foundation
import CoreData

extension TaskTracker {
  /// Sample tasks for preview/testing
  static func previewTasks(in context: NSManagedObjectContext) -> [TaskTracker] {
    let tasks = [
      ("Chill", "#FF1493"),
      ("Personal", "#FF8C00"),
      ("Career", "#00BFFF"),
      ("Health", "#9932CC"),
      ("Finances", "#CD853F"),
      ("Spiritual", "#4169E1"),
      ("Family", "#FFD700"),
      ("Chickie", "#DA70D6"),
      ("Social", "#32CD32"),
    ]
    
    return tasks.enumerated().map { index, task in
      let task = TaskTracker(context: context)
      task.name = task.name
      task.color = task.color
      task.order = Int16(index)
      task.createdAt = Date()
      return task
    }
  }
}

extension TaskTrackerLog {
  /// Sample task log for preview/testing
  static func previewLog(task: TaskTracker, in context: NSManagedObjectContext, for date: Date) -> TaskTrackerLog {
    let log = TaskTrackerLog(context: context)
    log.task = task
    
    // Create a random 15-minute to 1-hour block
    let randomHour = Int.random(in: 6...22)
    let randomMinute = [0, 15, 30, 45].randomElement() ?? 0
    let duration = [15, 30, 45, 60].randomElement() ?? 15
    
    var calendar = Calendar.current
    let dayStart = calendar.startOfDay(for: date)
    let components = DateComponents(hour: randomHour, minute: randomMinute)
    let start = calendar.date(byAdding: components, to: dayStart) ?? Date()
    let end = Date(timeInterval: TimeInterval(duration * 60), since: start)
    
    log.startDate = start
    log.endDate = end
    log.createdAt = Date()
    log.updatedAt = Date()
    
    return log
  }
}
