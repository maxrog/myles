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
    
    // TODO i think this is considering Sun-Sat as a week or something? Try getting it to be Monday
    private func generateBarMark(for run: MylesRun) -> BarMark {
        BarMark(x: .value("Label", run.endTime, unit: .weekOfMonth),
                y: .value("Value", run.distance))
    }
    
    var body: some View {
        let focusedRuns = health.focusedRunsFromPast(weekCount: numberOfWeeks)
        VStack {
            Chart(focusedRuns) { run in
                generateBarMark(for: run)
                    .foregroundStyle(run.colorForWorkout)
            }
        }
    }
}
