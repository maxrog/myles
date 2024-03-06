//
//  GoalsManager.swift
//  myles
//
//  Created by Max Rogers on 3/6/24.
//

import SwiftUI

// TODO - migrate to @Observable once @AppStorage is supported\

class GoalsManager: ObservableObject {

    @AppStorage(GoalKeys.weeklyMileage.rawValue) var weeklyMileageGoal: Int = 0
    
}

enum GoalKeys: String {
    case weeklyMileage
}
