//
//  HealthManager+Metrics.swift
//  myles
//
//  Created by Max Rogers on 12/28/23.
//

import Foundation

/*
 Health manager metrics related processing that doesn't require store queries
 */

extension HealthManager {
    
    /// Calculates the user's run streak (days in a row) starting from today
    func streakCount() -> Int {
        Logger.log(.action, "Calculating run streak", sender: String(describing: self))
        
        var streak = 0
        var currentDate = Date()
        var usedDates: [Date] = []
        
        for run in runs {
            let runDate = run.endTime
            let calendar = Calendar.current
            
            guard !usedDates.contains(where: ({ calendar.isDate($0, inSameDayAs: runDate) })) else { continue }
            
            if calendar.isDate(runDate, inSameDayAs: currentDate) {
                streak += 1
                Logger.log(.action, "+1 to run streak for \(runDate.shortCalendarDateFormat)", sender: String(describing: self))
            } else {
                if let nextDate = calendar.date(byAdding: .day, value: -1, to: currentDate) {
                    if calendar.isDate(runDate, inSameDayAs: nextDate) {
                        streak += 1
                        Logger.log(.action, "+1 to run streak for \(runDate.shortCalendarDateFormat)", sender: String(describing: self))
                    } else {
                        break
                    }
                }
            }
            usedDates.append(runDate)
            currentDate = runDate
        }
        
        Logger.log(.action, "Calculated \(streak) days run streak", sender: String(describing: self))
        return streak
    }
    
}
