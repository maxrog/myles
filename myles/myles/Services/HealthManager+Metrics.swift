//
//  HealthManager+Metrics.swift
//  myles
//
//  Created by Max Rogers on 12/28/23.
//

import Foundation

/*
 TODO - refactor to background tasks for performance
 */

/*
 Health manager metrics related processing that doesn't require store queries
 */

extension HealthManager {

    // MARK: General

    /// Returns the total distance for a given array of runs
    func runsTotalDistance(_ runs: [MylesRun]) -> Double {
        return runs.reduce(0) { partialResult, run in
            var valid = true
            switch run.workoutType {
            case .run:
                valid = goals.trackRuns
            case .hike, .walk:
                valid = goals.trackWalks
            default:
                valid = goals.trackCrosstraining
            }
            if valid {
                return partialResult + run.distance
            } else {
                return partialResult
            }
        }
    }
    /// Returns the total duration for a given array of runs
    func runsTotalDuration(_ runs: [MylesRun]) -> Double {
        return runs.reduce(0) { partialResult, run in
            var valid = true
            switch run.workoutType {
            case .run:
                valid = goals.trackRuns
            case .hike, .walk:
                valid = goals.trackWalks
            default:
                valid = goals.trackCrosstraining
            }
            if valid {
                return partialResult + run.duration
            } else {
                return partialResult
            }
        }
    }

    // MARK: Streak

    /// Calculates the user's run streak (days in a row) starting from today
    func runStreakCount() -> Int {
        MylesLogger.log(.action, "Calculating run streak", sender: String(describing: self))

        var streak = 0
        var currentDate = Date()
        var usedDates: [Date] = []

        for run in runs {
            let runDate = run.endTime
            let calendar = Calendar.current

            guard run.workoutType == .run, run.distance >= 1.0 else { continue }

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

    /// Calculates the user's step goal streak (days in a row) starting from today
    func stepStreakCount() -> Int {
        guard goals.dailyStepGoal > 0 else { return 0 }

        MylesLogger.log(.action, "Calculating step streak", sender: String(describing: self))

        var streak = 0
        var currentDate = Date()
        var usedDates: [Date] = []
        let goal = goals.dailyStepGoal
        let calendar = Calendar.current

        for step in steps {
            let stepDate = step.date
            let stepCount = Int(step.stepCount)

            guard stepCount > 0 else { continue }

            guard !usedDates.contains(where: { calendar.isDate($0, inSameDayAs: stepDate) }) else { continue }

            if calendar.isDate(stepDate, inSameDayAs: currentDate) {
                // If today, only increment streak if step count meets goal
                if stepCount >= goal {
                    streak += 1
                    MylesLogger.log(.action, "+1 to step streak for \(stepDate.shortCalendarDateFormat)", sender: String(describing: self))
                } else {
                    // Do not break the streak if today's steps do not meet the goal
                    MylesLogger.log(.action, "Today's steps (\(stepCount)) have not reached the goal (\(goal)), but day is not over", sender: String(describing: self))
                }
            } else {
                if let nextDate = calendar.date(byAdding: .day, value: -1, to: currentDate) {
                    if calendar.isDate(stepDate, inSameDayAs: nextDate) && stepCount >= goal {
                        streak += 1
                        MylesLogger.log(.action, "+1 to step streak for \(stepDate.shortCalendarDateFormat)", sender: String(describing: self))
                    } else {
                        break
                    }
                }
            }
            usedDates.append(stepDate)
            currentDate = stepDate
        }

        MylesLogger.log(.action, "Calculated \(streak) days step streak", sender: String(describing: self))
        return streak
    }

    // MARK: Spans

    /// Returns the user's activities based on filter type
    /// - Parameters:
    ///     - filter: A filter type to determine range of runs to process
    func focusedRuns(for filter: MetricsSpanFilterType) -> [MylesRun] {
        switch filter {
        case .week:
            return filterActivitiesForTrackingSettings(currentWeekRuns())
        case .month:
            return filterActivitiesForTrackingSettings(currentMonthRuns())
        case .year:
            return filterActivitiesForTrackingSettings(currentYearRuns())
        }
    }

    /// Returns the user's activities based on X number of date units
    /// Currently only supports weeks
    /// - Parameters:
    ///     - weekCount: The number of date units to retrieve
    func focusedRunsFromPast(weekCount: Int) -> [MylesRun] {
        return runsFromLast(weekCount)
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
            while steppingDate < weekEndDate {
                let matchingRuns = self.runs.filter({$0.endTime.isInSameDay(as: steppingDate)})
                if !matchingRuns.isEmpty {
                    weekRuns.append(contentsOf: matchingRuns)
                } else {
                    weekRuns.append(MylesRun.emptyRun(date: steppingDate))
                }
                guard let nextDay = calendar.date(byAdding: .day, value: 1, to: steppingDate) else { break }
                steppingDate = nextDay
            }
            return Array(weekRuns)
        } else {
            return Array(weekRuns)
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

    /// Returns the user's activities from the last X number of weeks
    private func runsFromLast(_ numberOfWeeks: Int) -> [MylesRun] {
        let calendar = Calendar.current
          let currentDate = Date()
          guard let startDate = calendar.date(byAdding: .weekOfYear, value: -numberOfWeeks, to: currentDate) else {
              return []
          }

          let filteredData = runs.filter { $0.endTime >= startDate }
          return filterActivitiesForTrackingSettings(filteredData)
    }

    /// Returns the user's longest activity from given number of weeks
    func longestRecentLongRun(_ numberOfWeeks: Int) -> MylesRun? {
        let allRuns = runsFromLast(numberOfWeeks).filter({ !$0.crossTraining })
        return allRuns.max() // max works based on distance (comparable conformance implementation)
    }

    /// Returns a filtered list of activities based on the user's tracking preferences
    private func filterActivitiesForTrackingSettings(_ runs: [MylesRun]) -> [MylesRun] {
        var filteredActivities = runs
        if !goals.trackRuns {
            filteredActivities.removeAll(where: ({ $0.workoutType == .run }))
        }
        if !goals.trackWalks {
            filteredActivities.removeAll(where: ({ $0.workoutType == .walk || $0.workoutType == .hike }))
        }
        if !goals.trackCrosstraining {
            filteredActivities.removeAll(where: ({ $0.crossTraining}))
        }
        return filteredActivities
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
