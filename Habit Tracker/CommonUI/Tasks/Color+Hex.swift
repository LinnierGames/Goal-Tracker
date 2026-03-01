//
//  Color+Hex.swift
//  Habit Tracker
//
//  Created by Erick Sanchez on 2/28/26.
//

import SwiftUI

extension Color {
    /// Initialize a Color from a hex string (e.g., "#FF1493" or "FF1493")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

/// Preset task colors as hex strings
enum TaskColorHex {
    static let chill = "#FF1493"      // Deep Pink/Magenta
    static let personal = "#FF8C00"   // Dark Orange
    static let career = "#00BFFF"     // Deep Sky Blue
    static let health = "#9932CC"     // Dark Orchid
    static let finances = "#CD853F"   // Peru/Brown
    static let spiritual = "#4169E1"  // Royal Blue
    static let family = "#FFD700"     // Gold/Yellow
    static let chickie = "#DA70D6"    // Orchid/Purple
    static let social = "#32CD32"     // Lime Green
    static let extra = "#808080"      // Gray (placeholder for 10th)
    
    static let all = [chill, personal, career, health, finances, spiritual, family, chickie, social, extra]
}
