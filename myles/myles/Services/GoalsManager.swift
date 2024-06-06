//
//  GoalsManager.swift
//  myles
//
//  Created by Max Rogers on 3/6/24.
//

import SwiftUI

// TODO - migrate to @Observable once this flow with user defaults works
// TODO - push notifications for when user reaches goal

/// Manager for user workout goals
class GoalsManager: ObservableObject {

    /// Shared user defaults
    let userDefaults = UserDefaults(suiteName: "group.9AS2TD23UD.com.marfodub.myles")

    static let shared = GoalsManager()

    private init() {
        if userDefaults?.value(forKey: GoalKeys.weeklyMileage.rawValue) != nil {
            self.weeklyMileageGoal = userDefaults?.integer(forKey: GoalKeys.weeklyMileage.rawValue) ?? 0
        }
        if userDefaults?.value(forKey: GoalKeys.dailySteps.rawValue) != nil {
            self.dailyStepGoal = userDefaults?.integer(forKey: GoalKeys.dailySteps.rawValue) ?? 0
        }
        if userDefaults?.value(forKey: GoalKeys.trackRuns.rawValue) != nil {
            self.trackRuns = userDefaults?.bool(forKey: GoalKeys.trackRuns.rawValue) ?? true
        }
        if userDefaults?.value(forKey: GoalKeys.trackWalks.rawValue) != nil {
            self.trackWalks = userDefaults?.bool(forKey: GoalKeys.trackWalks.rawValue) ?? true
        }
        if userDefaults?.value(forKey: GoalKeys.trackCrosstraining.rawValue) != nil {
            self.trackCrosstraining = userDefaults?.bool(forKey: GoalKeys.trackCrosstraining.rawValue) ?? false
        }
    }

    // MARK: Weekly Mileage

    /// User's weekly mileage goal
    @Published private(set) var weeklyMileageGoal: Int = 0 {
        didSet { saveWeeklyMileageGoal() }
    }
    func updateWeeklyMileageGoal(to newGoal: Int) {
        guard newGoal >= 0 else { return }
        self.weeklyMileageGoal = newGoal
    }
    private func saveWeeklyMileageGoal() {
        userDefaults?.setValue(weeklyMileageGoal, forKey: GoalKeys.weeklyMileage.rawValue)
    }

    // MARK: Daily Steps

    /// User's daily step goal
    @Published private(set) var dailyStepGoal: Int = 0 {
        didSet { saveDailyStepGoal() }
    }
    func updateDailyStepGoal(to newGoal: Int) {
        guard newGoal >= 0 else { return }
        self.dailyStepGoal = newGoal
    }
    private func saveDailyStepGoal() {
        userDefaults?.setValue(dailyStepGoal, forKey: GoalKeys.dailySteps.rawValue)
    }

    // MARK: Tracking Scope

    // TODO Refactor to DRY
    /*
     Enabled Tracking Types
     */
    @Published var trackRuns: Bool = true {
        didSet {
            userDefaults?.setValue(trackRuns, forKey: GoalKeys.trackRuns.rawValue)
        }
    }
    @Published var trackWalks: Bool = true {
        didSet {
            userDefaults?.setValue(trackWalks, forKey: GoalKeys.trackWalks.rawValue)
        }
    }
    @Published var trackCrosstraining: Bool = false {
        didSet {
            userDefaults?.setValue(trackCrosstraining, forKey: GoalKeys.trackCrosstraining.rawValue)
        }
    }
}

enum GoalKeys: String {
    case weeklyMileage, dailySteps, trackRuns, trackHikes, trackWalks, trackCrosstraining
}
