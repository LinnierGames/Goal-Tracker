//
//  Sleep+CoreDataClass.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 3/11/22.
//
//

import Foundation
import CoreData

@objc(FeelingSleepy)
public class FeelingSleepy: NSManagedObject {

  @nonobjc public class func fetchRequest() -> NSFetchRequest<FeelingSleepy> {
      return NSFetchRequest<FeelingSleepy>(entityName: "FeelingSleepy")
  }

  @NSManaged public var timestamp: Date
  @NSManaged public var activity: String
}
