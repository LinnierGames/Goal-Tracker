//
//  NSSet.swift
//  Tracker Tracker
//
//  Created by Erick Sanchez on 1/19/23.
//

import Foundation
import CoreData

extension NSSet {
  func allManagedObjects<T: NSManagedObject>() -> [T] {
    allObjects as! [T]
  }
}
