//
//  FoundationExtensions.swift
//  myles
//
//  Created by Max Rogers on 12/8/23.
//

import SwiftUI

// MARK: UserDefaults

extension UserDefaults {
    
    /// Store SwiftUI Color
    func setColor(_ color: Color, forKey key: String) {
        let cgColor = color.cgColor_
        let array = cgColor.components ?? []
        set(array, forKey: key)
    }

    /// Fetch SwiftUIColor
    func color(forKey key: String) -> Color {
        guard let array = object(forKey: key) as? [CGFloat] else { return .accentColor }
        let color = CGColor(colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, components: array)!
        return Color(color)
    }
    
}

// MARK: Date

extension Date {
    /// Calculate the difference in seconds between two dates
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    
    /// Calculate the number of days between two dates
    func daysBetween(_ otherDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: otherDate)
        return components.day ?? 0
    }
    
    /// Common date format
    var shortCalendarDateFormat: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.d.yy"
        return formatter.string(from: self)
    }
    /// Common date format
    var shortDayOfWeekDateFormat: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: self)
    }
}
  
