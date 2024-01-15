//
//  HealthManager+Metrics.swift
//  myles
//
//  Created by Max Rogers on 12/28/23.
//

import Foundation

/*
 TODO Add Logging
 Health manager metrics related processing that doesn't require store queries
 */

extension HealthManager {
    
    // MARK: General
    
    /// Returns the total distance for a given array of runs
    func runsTotalDistance(_ runs: [MylesRun]) -> Double {
        return runs.reduce(0) { partialResult, run in
            return partialResult + run.distance
        }
    }
    /// Returns the total duration for a given array of runs
    func runsTotalDuration(_ runs: [MylesRun]) -> Double {
        return runs.reduce(0) { partialResult, run in
            return partialResult + run.duration
        }
    }
    
    // MARK: Streak
    
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
    
    // MARK: Spans
    
    /// Returns the user's activities based on filter type
    /// - Parameters:
    ///     - filter: A filter type to determine range of runs to process
    func focusedRuns(for filter: MetricsSpanFilterType) -> [MylesRun] {
        switch filter {
        case .week:
            return currentWeekRuns()
        case .month:
            return currentMonthRuns()
        case .year:
            return currentYearRuns()
        }
    }
    
    /// Returns the current calendar's elapsed days within a given span
    /// - Parameters:
    ///     - spanFilter: The span in which to calculated the elapsed days
    func elapsedDaysForSpan(_ spanFilter: MetricsSpanFilterType) -> Double {
        let calendar = Calendar.current
        let currentDate = Date()
        switch spanFilter {
        case .week:
            return 7
        case .month:
            if let monthStartDate = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) {
                    let numberOfDaysElapsed = calendar.dateComponents([.day], from: monthStartDate, to: currentDate).day ?? 0
                    return Double(numberOfDaysElapsed)
            } else {
                return 30
            }
        case .year:
            if let yearStartDate = calendar.date(from: calendar.dateComponents([.year], from: currentDate)) {
                let numberOfDaysElapsed = calendar.dateComponents([.day], from: yearStartDate, to: currentDate).day ?? 0
                return Double(numberOfDaysElapsed)
            } else {
                return 365
            }
        }
    }
    
    /// Returns a grouped day count for a current span. E.g. if a month span, will be grouped by week (7), if year span, grouped by month (30ish)
    /// - Parameters:
    ///     - spanFilter: The span in which to calculated the elapsed days
    func groupedDayCountForSpan(_ spanFilter: MetricsSpanFilterType) -> Double {
        switch spanFilter {
        case .week:
            return 1
        case .month:
            return 7
        case .year:
            let calendar = Calendar.current
            let currentDate = Date()
            if let yearStartDate = calendar.date(from: calendar.dateComponents([.year], from: currentDate)) {
                let components = calendar.dateComponents([.year, .month, .day], from: yearStartDate, to: currentDate)
                guard let numberOfMonthsElapsed = components.month else {
                    return 30.44
                }
                var daysInMonths: [Int] = []
                for month in 0..<numberOfMonthsElapsed {
                    guard let startDateOfMonth = calendar.date(byAdding: .month, value: month, to: yearStartDate),
                          let endDateOfMonth = calendar.date(byAdding: .month, value: month + 1, to: yearStartDate),
                          let numberOfDaysInMonth = calendar.dateComponents([.day], from: startDateOfMonth, to: endDateOfMonth).day else {
                        continue
                    }
                    daysInMonths.append(numberOfDaysInMonth)
                }
                let totalDays = daysInMonths.reduce(0, +)
                let numberOfMonths = daysInMonths.count
                let averageDays = max(elapsedDaysForSpan(.month), Double(totalDays) / Double(numberOfMonths))
                return averageDays
            }
            return 30.44
        }
    }
    
    /// Returns the user's activities based on the current week (M-S)
    private func currentWeekRuns() -> [MylesRun] {
        let currentDate = Date()
        var calendar = Calendar.current
        // TODO account for user's phone calendar preference or have option in settings page
        calendar.firstWeekday = 2
        var weekRuns: [MylesRun] = []
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
    
    /// Returns the user's activities based on the current month
    private func currentMonthRuns() -> [MylesRun] {
        let currentDate = Date()
        let calendar = Calendar.current
        var monthRuns: [MylesRun] = []
        if let monthStartDate = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)),
           let monthEndDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStartDate) {
            var steppingDate = monthStartDate
            while steppingDate <= monthEndDate {
                monthRuns.append(contentsOf: self.runs.filter({$0.endTime.isInSameDay(as: steppingDate)}))
                guard let nextDay = calendar.date(byAdding: .day, value: 1, to: steppingDate) else { break }
                steppingDate = nextDay
            }
            return monthRuns
        } else {
            return monthRuns
        }
    }
    
    /// Returns the user's activities based on the current year
    private func currentYearRuns() -> [MylesRun] {
        let currentDate = Date()
        let calendar = Calendar.current
        var yearRuns: [MylesRun] = []
        if let yearStartDate = calendar.date(from: calendar.dateComponents([.year], from: currentDate)),
                let yearEndDate = calendar.date(byAdding: DateComponents(year: 1, day: -1), to: yearStartDate) {
            var steppingDate = yearStartDate
            while steppingDate <= yearEndDate {
                yearRuns.append(contentsOf: self.runs.filter({$0.endTime.isInSameDay(as: steppingDate)}))
                guard let nextDay = calendar.date(byAdding: .day, value: 1, to: steppingDate) else { break }
                steppingDate = nextDay
            }
            return yearRuns
        } else {
            return yearRuns
        }
    }
    
}
