//
//  SteppedMetricChartView.swift
//  myles
//
//  Created by Max Rogers on 3/28/24.
//

import SwiftUI
import Charts

/// Simple Chart view that displays x amount of past weeks
struct SteppedMetricChartView: View {
    
    @Environment(HealthManager.self) var health
    @Binding var numberOfWeeks: Int
    
    private func generateBarMark(for run: MylesRun) -> BarMark {
        BarMark(x: .value("Label", run.endTime, unit: .weekOfMonth),
                y: .value("Value", run.distance))
    }
    
    var body: some View {
        Chart(health.focusedRunsFromPast(weekCount: numberOfWeeks)) { run in
            generateBarMark(for: run)
                .foregroundStyle(MetricChartView.colorForWorkout(run))
        }
    }
}
