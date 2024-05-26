//
//  StepsGoalWidgetView.swift
//  MylesWidgetExtension
//
//  Created by Max Rogers on 5/25/24.
//

import SwiftUI

/// A view designed for a Widget that displays a summary of steps
struct StepsGoalWidgetView: View {
    
    let entry: MetricEntry
    let goals = GoalsManager.shared
    let geometry: GeometryProxy
    
    var body: some View {
        let currentSteps = entry.dailySteps
        let goal = goals.dailyStepGoal
        VStack {
            Spacer()
            MetricsProgressBarView(currentValue: Int(currentSteps),
                                   totalValue: goal,
                                   descriptionText: "Daily Goal: \(goal) steps")
            Spacer()
        }
    }
}

/// A view designed for a Widget that displays a compact summary of steps
struct CompactStepsGoalWidgetView: View {
    
    let entry: MetricEntry
    let goals = GoalsManager.shared
    let geometry: GeometryProxy
    
    var body: some View {
        let currentSteps = entry.dailySteps
        let goal = goals.dailyStepGoal
        HStack(spacing: 0) {
            Spacer()
            VStack(spacing: 0) {
                if goal > 0 {
                    Label("\(goal)", systemImage: "star.circle.fill")
                        .font(.custom("norwester", size: 10))
                        .labelStyle(MylesIconLabel())
                }
                Spacer()
                MetricGaugeView(progress: min(1.0,
                                              currentSteps / Double(goals.dailyStepGoal)),
                                total: "\(Int(currentSteps))",
                                goal: nil,
                                metric: NSLocalizedString("steps", comment: "steps"))
                .frame(width: geometry.size.height * 0.82, height: geometry.size.height * 0.82)
                Spacer()
            }
            Spacer()
        }
    }
}
