//
//  MetricChartView.swift
//  myles
//
//  Created by Max Rogers on 1/14/24.
//

import SwiftUI
import Charts

/*
 TODO different colors for crosstraining
 */

/// Simple Chart view based on given runs and filters
struct MetricChartView: View {
    
    @EnvironmentObject var theme: ThemeManager
    @Environment(HealthManager.self) var health
    
    let focusedRuns: [MylesRun]
    let primaryFilter: MetricsPrimaryFilterType
    let spanFilter: MetricsSpanFilterType
    
    private func generateBarMark(for run: MylesRun) -> BarMark {
        switch primaryFilter {
        case .distance:
            switch spanFilter {
            case .week:
                BarMark(x: .value("Label", run.endTime.shortDayOfWeekDateFormat),
                        y: .value("Value", run.distance))
            case .month:
                BarMark(x: .value("Label", run.endTime, unit: .weekOfMonth),
                        y: .value("Value", run.distance))
            case .year:
                BarMark(x: .value("Label", run.endTime.shortMonthOfYearDateFormat),
                        y: .value("Value", run.distance))
            }
        case .duration:
            switch spanFilter {
            case .week:
                BarMark(x: .value("Label", run.endTime.shortDayOfWeekDateFormat),
                        y: .value("Value", run.durationMinutes))
            case .month:
                BarMark(x: .value("Label", run.endTime, unit: .weekOfMonth),
                        y: .value("Value", run.durationMinutes))
            case .year:
                BarMark(x: .value("Label", run.endTime.shortMonthOfYearDateFormat),
                        y: .value("Value", run.durationMinutes))
            }
        }
    }
    
    private func colorForWorkout(_ run: MylesRun) -> Color {
        switch run.workoutType {
        case .run:
            return Color(uiColor:UIColor(named: "mylesLight") ?? .yellow)
        case .hike, .walk:
            return Color(uiColor: UIColor(named: "mylesDark") ?? .red)
        case .crosstrain:
            return Color(uiColor: UIColor(named: "CosmicLatte") ?? .white)
        }
    }
    
    var body: some View {
        Chart(focusedRuns) { run in
            generateBarMark(for: run)
                .foregroundStyle(colorForWorkout(run))
        }
    }
}

#Preview {
    MetricChartView(focusedRuns: [MylesRun.testRun], primaryFilter: .distance, spanFilter: .week)
}
