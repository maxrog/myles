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
        MylesLogger.log(.action, "Calculating run streak", sender: String(describing: self))
        
        var streak = 0
        var currentDate = Date()
        var usedDates: [Date] = []
        
        for run in runs {
            let runDate = run.endTime
            let calendar = Calendar.current
            
            guard !usedDates.contains(where: ({ calendar.isDate($0, inSameDayAs: runDate) })) else { continue }
            
            if calendar.isDate(runDate, inSameDayAs: currentDate) {
                streak += 1
                MylesLogger.log(.action, "+1 to run streak for \(runDate.shortCalendarDateFormat)", sender: String(describing: self))
            } else {
                if let nextDate = calendar.date(byAdding: .day, value: -1, to: currentDate) {
                    if calendar.isDate(runDate, inSameDayAs: nextDate) {
                        streak += 1
                        MylesLogger.log(.action, "+1 to run streak for \(runDate.shortCalendarDateFormat)", sender: String(describing: self))
                    } else {
                        break
                    }
                }
            }
            usedDates.append(runDate)
            currentDate = runDate
        }
        
        MylesLogger.log(.action, "Calculated \(streak) days run streak", sender: String(describing: self))
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
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let currentDate = Date()
        switch spanFilter {
        case .week:
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)) ?? currentDate
            let daysElapsed = calendar.dateComponents([.day], from: startOfWeek, to: currentDate).day ?? 0 + 1
            return Double(daysElapsed)
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
    
    /// Grouped runs by span
    /// - Parameters:
    ///     - spanFilter: The span in which to calculated the elapsed days
    ///     - focusedRuns: The runs to group
    func groupedRunsForSpan(_ spanFilter: MetricsSpanFilterType, focusedRuns: [MylesRun]) -> [Date: [MylesRun]] {
        var calendar = Calendar.current
        // TODO account for user's phone calendar preference or have option in settings page (check app wide for other usage)
        calendar.firstWeekday = 2
        var groupedRuns: [Date : [MylesRun]] = [:]
        switch spanFilter {
        case .week:
            let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
            let startOfWeek = calendar.date(from: components) ?? Date()
            groupedRuns[startOfWeek] = focusedRuns
        case .month:
            for run in focusedRuns {
                let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: run.endTime)) ?? Date()
                if var weekRuns = groupedRuns[startOfWeek] {
                    weekRuns.append(run)
                    groupedRuns[startOfWeek] = weekRuns
                } else {
                    groupedRuns[startOfWeek] = [run]
                }
            }
        case .year:
            for run in focusedRuns {
                let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: run.endTime)) ?? Date()
                if var monthRuns = groupedRuns[startOfMonth] {
                    monthRuns.append(run)
                    groupedRuns[startOfMonth] = monthRuns
                } else {
                    groupedRuns[startOfMonth] = [run]
                }
            }
        }
        return groupedRuns
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
            return Array(weekRuns.prefix(7))
        } else {
            return Array(weekRuns.prefix(7))
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

/// A main filter, either distance or duration
enum MetricsPrimaryFilterType: Int {
    case distance, duration
}
/// A filter representing a span of time
enum MetricsSpanFilterType: Int {
    case week, month, year
}
