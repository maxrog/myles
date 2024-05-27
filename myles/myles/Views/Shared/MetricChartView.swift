//
//  MetricChartView.swift
//  myles
//
//  Created by Max Rogers on 1/14/24.
//

/*
 TODO look at this if anything useful https://www.devtechie.com/community/public/posts/154033-new-in-swiftui-4-charts-bar-chart
 */

import SwiftUI
import Charts

/*
 TODO - display exact total milage/duration on tap
 TODO scrollable
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
    
    var body: some View {
        Chart(focusedRuns) { run in
            generateBarMark(for: run)
                .foregroundStyle(run.colorForWorkout)
        }
    }
}

extension MetricChartView {
    
    /// Returns views to be used within a legend indicating the chart colors
    static func legend(for runs: [MylesRun], displayingDistance: Bool) -> [some View] {
        var uniqueRuns: [MylesRun] = []
        for run in runs {
            guard !run.emptyPlaceholder, run.distance > 0 || run.duration > 0 else { continue }
            if displayingDistance && run.distance == 0 { continue }
            if !uniqueRuns.contains(where: {
                $0.crossTraining && run.crossTraining ||
                $0.workoutType == run.workoutType
            }) {
                uniqueRuns.append(run)
            }
        }
        return uniqueRuns.map { 
            $0.workoutTypeSymbol
                .frame(width: 20, height: 20)
                .padding(6)
                .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke($0.colorForWorkout, lineWidth: 4)
                    )
        }
    }
}

#Preview {
    MetricChartView(focusedRuns: [MylesRun.testRun], primaryFilter: .distance, spanFilter: .week)
}
