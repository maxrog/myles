//
//  ChartMetricWidgetView.swift
//  MylesWidgetExtension
//
//  Created by Max Rogers on 3/8/24.
//

import SwiftUI
import Charts

/// A view designed for a Widget that displays a chart next to a gauge
struct ChartMetricWidgetView: View {
    
    let entry: MetricEntry
    let goals = GoalsManager.shared
    let geometry: GeometryProxy
    
    var body: some View {
        let totalMiles = entry.focusedRuns.reduce(0) { $0 + $1.distance }
        let maxRun = entry.focusedRuns.max(by: { $0.distance < $1.distance })
        HStack {
            Chart(entry.focusedRuns) { run in
                var firstRun = entry.focusedRuns.first(where: { $0.endTime.isInSameDay(as: run.endTime) })
                generateBarMark(for: run)
                    .annotation(position: .bottom, alignment: .bottom, spacing: 4) {
                        if run == firstRun {
                            Text(run.endTime.veryShortDayOfWeekDateFormat)
                                .font(.custom("norwester", size: 10))
                                .foregroundStyle(run.endTime <= Date() ? Color.primary : Color.primary.opacity(0.5))
                        }
                    }
                    .annotation(position: .top, alignment: .center, spacing: 4) {
                        Text("\((maxRun?.distance ?? 0 > 0 && maxRun == run) ? maxRun!.distance.prettyString : "")")
                            .font(.custom("norwester", size: 10))
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .foregroundStyle(run.colorForWorkout)
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            
            MetricGaugeView(progress: min(1.0,
                                          totalMiles / Double(goals.weeklyMileageGoal)),
                            total: totalMiles.prettyString,
                            goal: goals.weeklyMileageGoal,
                            metric: NSLocalizedString("miles", comment: "miles"))
            .frame(height: geometry.size.height * 0.9)
        }
    }
    
    
    
    private func generateBarMark(for run: MylesRun) -> BarMark {
        switch entry.primaryFilter {
        case .distance:
            switch entry.spanFilter {
            case .week:
                BarMark(x: .value("Label", run.endTime.shortDayOfWeekDateFormat),
                        y: .value("Value", run.distance))
            case .month:
                BarMark(x: .value("Label", run.endTime, unit: .weekOfMonth),
                        y: .value("Value", run.distance))
            case .year:
                BarMark(x: .value("Label", run.endTime, unit: .weekOfYear),
                        y: .value("Value", run.distance))
            }
        case .duration:
            switch entry.spanFilter {
            case .week:
                BarMark(x: .value("Label", run.endTime.shortDayOfWeekDateFormat),
                        y: .value("Value", run.durationMinutes))
            case .month:
                BarMark(x: .value("Label", run.endTime, unit: .weekOfMonth),
                        y: .value("Value", run.durationMinutes))
            case .year:
                BarMark(x: .value("Label", run.endTime, unit: .weekOfYear),
                        y: .value("Value", run.durationMinutes))
            }
        }
    }
}
