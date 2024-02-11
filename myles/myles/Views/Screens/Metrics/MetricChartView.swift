//
//  MetricChartView.swift
//  myles
//
//  Created by Max Rogers on 1/14/24.
//

import SwiftUI
import Charts

/// Simple Chart view based on given runs and filters
struct MetricChartView: View {
    
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
                BarMark(x: .value("Label", "wk \(run.endTime.weekOfMonthDateFormat)"),
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
                BarMark(x: .value("Label", "wk \(run.endTime.weekOfMonthDateFormat)"),
                        y: .value("Value", run.durationMinutes))
            case .year:
                BarMark(x: .value("Label", run.endTime.shortMonthOfYearDateFormat),
                        y: .value("Value", run.durationMinutes))
            }
        }
    }
    
    var body: some View {
        Chart(focusedRuns) { run in
            generateBarMark(for: run)
        }
    }
}

#Preview {
    MetricChartView(focusedRuns: [MylesRun.testRun], primaryFilter: .distance, spanFilter: .week)
}
