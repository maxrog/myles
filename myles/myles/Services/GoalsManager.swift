//
//  GoalsManager.swift
//  myles
//
//  Created by Max Rogers on 3/6/24.
//

import SwiftUI

// TODO - migrate to @Observable once this flow with user defaults works

/// Manager for user workout goals
class GoalsManager: ObservableObject {
    
    /// Shared user defaults
    let userDefaults = UserDefaults(suiteName: "group.com.marfodub.myles")
    
    init() {
        self.weeklyMileageGoal = userDefaults?.integer(forKey: GoalKeys.weeklyMileage.rawValue) ?? 0
    }

    // MARK: Weekly Mileage
    
    /// User's weekly mileage goal
    @Published private(set) var weeklyMileageGoal: Int = 0 {
        didSet { saveWeeklyMileageGoal() }
    }
    func updateWeeklyMileageGoal(to newGoal: Int) {
        guard newGoal > 0 else { return }
        self.weeklyMileageGoal = newGoal
    }
    private func saveWeeklyMileageGoal() {
        userDefaults?.setValue(weeklyMileageGoal, forKey: GoalKeys.weeklyMileage.rawValue)
    }
    
}

enum GoalKeys: String {
    case weeklyMileage
}
