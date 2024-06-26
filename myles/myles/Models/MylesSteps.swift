//
//  MylesSteps.swift
//  myles
//
//  Created by Max Rogers on 6/17/24.
//

import Foundation
import Observation

@Observable
class MylesSteps: Identifiable, Codable, Equatable {

    /// A UUID for the step log
    let id: UUID
    /// Steps taken
    let stepCount: Double
    /// Date the steps were taken
    let date: Date

    static func == (lhs: MylesSteps, rhs: MylesSteps) -> Bool {
        lhs.id == rhs.id
    }

    init(id: UUID = UUID(), stepCount: Double, date: Date) {
        self.id = id
        self.stepCount = stepCount
        self.date = date
    }
}
