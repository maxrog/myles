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
 TODO - display/do something on tap
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
                .foregroundStyle(Self.colorForWorkout(run))
        }
    }
}

extension MetricChartView {
    static func colorForWorkout(_ run: MylesRun) -> Color {
        switch run.workoutType {
        case .run:
            return run.emptyPlaceholder ? Color(.clear) : Color(uiColor:UIColor(named: "mylesLight") ?? .yellow)
        case .hike, .walk:
            return Color(uiColor: UIColor(named: "mylesDark") ?? .red)
        default:
            return Color(uiColor: UIColor(named: "CosmicLatte") ?? .white)
        }
    }
}

#Preview {
    MetricChartView(focusedRuns: [MylesRun.testRun], primaryFilter: .distance, spanFilter: .week)
}
