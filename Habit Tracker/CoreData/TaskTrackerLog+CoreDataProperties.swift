//
//  TaskLog+CoreDataProperties.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 3/1/26.
//
//

import Foundation
import CoreData


typealias TaskTrackerLogCoreDataPropertiesSet = NSSet

extension TaskTrackerLog {
  
  @nonobjc class func fetchRequest() -> NSFetchRequest<TaskTrackerLog> {
    return NSFetchRequest<TaskTrackerLog>(entityName: "TaskTrackerLog")
  }
  
  @NSManaged var createdAt: Date
  @NSManaged var endDate: Date
  @NSManaged var startDate: Date
  @NSManaged var updatedAt: Date
  @NSManaged var task: TaskTracker
  
}

extension TaskTrackerLog : Identifiable {
  
}
