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
        
    /// Returns the user's activities based on the current week (M-S)
    func currentWeekRuns() -> [MylesRun] {
        let currentDate = Date()
        var calendar = Calendar.current
        // TODO account for user's phone calendar preference or have option in settings page
        calendar.firstWeekday = 2
        var weekRuns: [MylesRun] = []
        // Get the start and end dates of the current week
        if let weekStartDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)),
            let weekEndDate = calendar.date(byAdding: .weekOfYear, value: 1, to: weekStartDate) {
            
            var steppingDate = weekStartDate
            
            while steppingDate <= weekEndDate {
                let matchingRuns = self.runs.filter({$0.endTime.isInSameDay(as: steppingDate)})
                if !matchingRuns.isEmpty {
                    weekRuns.append(contentsOf: matchingRuns)
                } else {
                    weekRuns.append(MylesRun.emptyRun(date: steppingDate))
                }
                guard let nextDay = calendar.date(byAdding: .day, value: 1, to: steppingDate) else { break }
                steppingDate = nextDay
            }
            return weekRuns
        } else {
            return weekRuns
        }
    }
}
