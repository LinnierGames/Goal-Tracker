//
//  KeyPath.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 3/16/22.
//

import Foundation

extension KeyPath {
    var stringValue: String {
        NSExpression(forKeyPath: self).keyPath
    }
}
