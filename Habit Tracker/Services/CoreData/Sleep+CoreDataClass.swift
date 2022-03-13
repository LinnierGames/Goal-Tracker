//
//  Sleep+CoreDataClass.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 3/11/22.
//
//

import Foundation
import CoreData

@objc(Sleep)
public class Sleep: NSManagedObject {

  @nonobjc public class func fetchRequest() -> NSFetchRequest<Sleep> {
      return NSFetchRequest<Sleep>(entityName: "Sleep")
  }

  @NSManaged public var timestamp: Date
  @NSManaged public var activity: String
}
