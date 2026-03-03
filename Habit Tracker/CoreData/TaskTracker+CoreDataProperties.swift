//
//  Task+CoreDataProperties.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 3/1/26.
//
//

import Foundation
import CoreData


typealias TaskTrackerCoreDataPropertiesSet = NSSet

extension TaskTracker {
  
  @nonobjc class func fetchRequest() -> NSFetchRequest<TaskTracker> {
    return NSFetchRequest<TaskTracker>(entityName: "TaskTracker")
  }
  
  @NSManaged var color: String
  @NSManaged var createdAt: Date
  @NSManaged var name: String
  @NSManaged var order: Int16
  @NSManaged var childTasks: NSSet
  @NSManaged var logs: NSSet
  @NSManaged var parentTask: TaskTracker?
  
}

// MARK: Generated accessors for childTasks
extension TaskTracker {
  
  @objc(addChildTasksObject:)
  @NSManaged func addToChildTasks(_ value: TaskTracker)
  
  @objc(removeChildTasksObject:)
  @NSManaged func removeFromChildTasks(_ value: TaskTracker)
  
  @objc(addChildTasks:)
  @NSManaged func addToChildTasks(_ values: NSSet)
  
  @objc(removeChildTasks:)
  @NSManaged func removeFromChildTasks(_ values: NSSet)
  
}

// MARK: Generated accessors for logs
extension TaskTracker {
  
  @objc(addLogsObject:)
  @NSManaged func addToLogs(_ value: TaskTrackerLog)
  
  @objc(removeLogsObject:)
  @NSManaged func removeFromLogs(_ value: TaskTrackerLog)
  
  @objc(addLogs:)
  @NSManaged func addToLogs(_ values: NSSet)
  
  @objc(removeLogs:)
  @NSManaged func removeFromLogs(_ values: NSSet)
  
}

extension TaskTracker : Identifiable {
  
}
