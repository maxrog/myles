//
//  CompactMetricWidgetView.swift
//  MylesWidgetExtension
//
//  Created by Max Rogers on 3/8/24.
//

import SwiftUI

/// A view designed for a Widget that displays a compact summary of metrics
struct CompactMetricWidgetView: View {
    
    let entry: MetricEntry
    let goals = GoalsManager()
    let geometry: GeometryProxy
    
    var body: some View {
        let totalMiles = entry.focusedRuns.reduce(0) { $0 + $1.distance }
        let goal = goals.weeklyMileageGoal
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
                                              totalMiles / Double(goals.weeklyMileageGoal)),
                                total: totalMiles.prettyString,
                                goal: nil,
                                metric: NSLocalizedString("mi", comment: "miles"))
                .frame(width: geometry.size.height * 0.82, height: geometry.size.height * 0.82)
                Spacer()
            }
            Spacer()
        }
    }
}
