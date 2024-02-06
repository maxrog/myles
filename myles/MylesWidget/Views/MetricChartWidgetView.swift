//
//  MetricChartWidgetView.swift
//  myles
//
//  Created by Max Rogers on 1/24/24.
//

import SwiftUI
import WidgetKit
import Charts

/// A widget view for displaying metrics including a chart
struct MetricChartWidgetView: View {
    
    let entry: MetricEntry
        
        private func generateBarMark(for run: MylesRun) -> BarMark {
            switch entry.primaryFilter {
            case .distance:
                switch entry.spanFilter {
                case .week:
                    BarMark(x: .value("Label", run.endTime.veryShortDayOfWeekDateFormat),
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
                    BarMark(x: .value("Label", run.endTime.veryShortDayOfWeekDateFormat),
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
        
        var body: some View {
            Chart(entry.focusedRuns) { run in
                generateBarMark(for: run)
            }
        }
}

#Preview {
    MetricChartWidgetView(entry: MetricEntry(date: .now,
                                             focusedRuns: [MylesRun.testRun], 
                                             primaryFilter: .distance,
                                             spanFilter: .week))
}
