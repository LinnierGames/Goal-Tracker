//
//  Date+GridHelpers.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 2/28/26.
//

import Foundation

/// Defines the granularity and layout of the time grid
enum GridMode: CaseIterable {
    case fifteenMinDaily
    case hourly
    case weekly
    case monthly
    
    /// Number of columns in the grid for this mode
    var cellsPerRow: Int {
        switch self {
        case .fifteenMinDaily: return 4
        case .hourly: return 24
        case .weekly, .monthly: return 7
        }
    }
    
    /// How long each cell represents in seconds
    var cellDuration: TimeInterval {
        switch self {
        case .fifteenMinDaily: return 15 * 60
        case .hourly: return 60 * 60
        case .weekly, .monthly: return 24 * 60 * 60
        }
    }
    
    /// Number of rows in the grid for this mode
    var rowCount: Int {
        switch self {
        case .fifteenMinDaily: return 24  // 24 hours
        case .hourly: return 1             // Full day in one row
        case .weekly: return 1             // 7 days in one row
        case .monthly: return 5            // 4-5 weeks
        }
    }
    
    /// Label format and count for time axis
    var timeAxisLabels: [String] {
        switch self {
        case .fifteenMinDaily:
            return (0..<24).map { "\($0)" }
        case .hourly:
            return ["Hour"]
        case .weekly:
            return ["Week"]
        case .monthly:
            return ["Month"]
        }
    }
    
    /// Human-readable description of one cell's duration
    var cellDescription: String {
        switch self {
        case .fifteenMinDaily: return "15min"
        case .hourly: return "1h"
        case .weekly, .monthly: return "1 day"
        }
    }
}

extension Date {
    /// Get the start of the day in the device's local timezone
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// Get the start of the week (Monday) in the device's local timezone
    func startOfWeek2() -> Date {
        var calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self.startOfDay()
    }
    
    /// Get the start of the month in the device's local timezone
    func startOfMonth() -> Date {
        var calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self.startOfDay()
    }
    
    /// Compute the grid cell index for a given TaskLog in a specific GridMode
    /// - Parameters:
    ///   - mode: The GridMode to compute for
    ///   - referenceDate: The date being displayed (used as anchor for the grid)
    /// - Returns: (row: Int, column: Int) representing position in grid, or nil if out of bounds
    func cellPosition(in mode: GridMode, referenceDate: Date) -> (row: Int, column: Int)? {
        let calendar = Calendar.current
        let cellDuration = mode.cellDuration
        
        let referenceStart: Date
        switch mode {
        case .fifteenMinDaily:
            referenceStart = referenceDate.startOfDay()
        case .hourly:
            referenceStart = referenceDate.startOfDay()
        case .weekly:
            referenceStart = referenceDate.startOfWeek
        case .monthly:
            referenceStart = referenceDate.startOfMonth()
        }
        
        let timeInterval = self.timeIntervalSince(referenceStart)
        guard timeInterval >= 0 else { return nil }
        
        let cellIndex = Int(timeInterval / cellDuration)
        let row = cellIndex / mode.cellsPerRow
        let column = cellIndex % mode.cellsPerRow
        
        guard row < mode.rowCount else { return nil }
        
        return (row, column)
    }
    
    /// Compute the date range represented by a grid cell
    /// - Parameters:
    ///   - row: Row index in grid
    ///   - column: Column index in grid
    ///   - mode: GridMode defining grid structure
    ///   - referenceDate: The date being displayed
    /// - Returns: (startDate: Date, endDate: Date) for that cell
    static func dateRange(
        for row: Int,
        column: Int,
        in mode: GridMode,
        referenceDate: Date
    ) -> (Date, Date) {
        let calendar = Calendar.current
        let cellDuration = mode.cellDuration
        
        let referenceStart: Date
        switch mode {
        case .fifteenMinDaily:
            referenceStart = referenceDate.startOfDay()
        case .hourly:
            referenceStart = referenceDate.startOfDay()
        case .weekly:
            referenceStart = referenceDate.startOfWeek
        case .monthly:
            referenceStart = referenceDate.startOfMonth()
        }
        
        let cellIndex = row * mode.cellsPerRow + column
        let cellStartTime = cellIndex * Int(cellDuration)
        
        let startDate = calendar.date(
            byAdding: .second,
            value: cellStartTime,
            to: referenceStart
        ) ?? referenceStart
        
        let endDate = calendar.date(
            byAdding: .second,
            value: cellStartTime + Int(cellDuration),
            to: referenceStart
        ) ?? referenceStart
        
        return (startDate, endDate)
    }
    
    /// Get the time label for a row in the grid
    /// - Parameters:
    ///   - row: Row index in grid
    ///   - mode: GridMode defining grid structure
    ///   - referenceDate: The date being displayed
    /// - Returns: Human-readable label for that time row (e.g., "Hour 9", "Monday")
    static func rowLabel(
        for row: Int,
        in mode: GridMode,
        referenceDate: Date
    ) -> String {
        let calendar = Calendar.current
        
        switch mode {
        case .fifteenMinDaily:
            return "Hour \(row)"
            
        case .hourly:
            return calendar.dateComponents([.month, .day], from: referenceDate).description
            
        case .weekly:
            let weekStart = referenceDate.startOfWeek
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d"
            return dateFormatter.string(from: weekStart)
            
        case .monthly:
            let monthStart = referenceDate.startOfMonth()
            let weekOffset = row * 7
            if let weekDate = calendar.date(byAdding: .day, value: weekOffset, to: monthStart) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d"
                return dateFormatter.string(from: weekDate)
            }
            return "Week \(row + 1)"
        }
    }
}
