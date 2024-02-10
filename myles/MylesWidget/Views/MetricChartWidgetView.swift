//
//  MetricChartWidgetView.swift
//  myles
//
//  Created by Max Rogers on 1/24/24.
//

import SwiftUI
import WidgetKit
import Charts

// TODO use myles red colors, base light,med, dark on distance compared to rest of week
// TODO custom font
// TODO issue with duplicate x value labels. Maybe try putting custom label above the bar mark with short day of week

/// A widget view for displaying metrics including a chart
struct MetricChartWidgetView: View {
    
    let entry: MetricEntry
    
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
    
    var body: some View {
        // TODO distance vs duration switch here
        let totalMiles = entry.focusedRuns.reduce(0) { $0 + $1.distance }
        let maxRun = entry.focusedRuns.max(by: { $0.distance < $1.distance })
        GeometryReader { geo in
            HStack {
                Chart(entry.focusedRuns) { run in
                    generateBarMark(for: run)
                        .annotation(position: .bottom, alignment: .bottom, spacing: 4) {
                            Text(run.endTime.veryShortDayOfWeekDateFormat)
                                .font(.custom("norwester", size: 8))
                        }
                        .annotation(position: .top, alignment: .center, spacing: 4) {
                            Text("\((maxRun?.distance ?? 0 > 0 && maxRun == run) ? maxRun!.distance.prettyString : "")")
                                .font(.custom("norwester", size: 10))
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                
                // TODO 30 should be user's goal
                Gauge(value: totalMiles, in: 0...30) {
                    VStack {
                        Text(totalMiles.prettyString)
                            .font(.custom("norwester", size: 20))
                        Text(NSLocalizedString("miles", comment: "miles"))
                            .font(.custom("norwester", size: 10))
                    }
                }
                .gaugeStyle(.accessoryCircularCapacity)
                .frame(width: geo.size.width / 2.5, height: geo.size.height)
            }
        }
    }
}



#Preview {
    MetricChartWidgetView(entry: MetricEntry(date: .now,
                                             focusedRuns: [MylesRun.testRun], 
                                             primaryFilter: .distance,
                                             spanFilter: .week))
}
