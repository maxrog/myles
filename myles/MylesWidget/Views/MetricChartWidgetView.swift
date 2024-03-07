//
//  MetricChartWidgetView.swift
//  myles
//
//  Created by Max Rogers on 1/24/24.
//

import SwiftUI
import WidgetKit
import Charts

// TODO case where there's no miles (data get messed up for whatever reason), let's have an empty view
// TODO custom font

/// A widget view for displaying metrics including a chart
struct MetricChartWidgetView: View {
    
    let entry: MetricEntry
    let goals = GoalsManager()
    
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
                        .foregroundStyle(by: .value(run.endTime.shortDayOfWeekDateFormat, run.distance))
                }
                .chartForegroundStyleScale(
                    domain: .automatic,
                    range: [
                        Color(uiColor: UIColor(named: "CosmicLatte") ?? .white),
                        Color(uiColor:UIColor(named: "mylesLight") ?? .yellow),
                        Color(uiColor:UIColor(named: "mylesMedium") ?? .orange),
                        Color(uiColor: UIColor(named: "mylesDark") ?? .red)
                    ]
                )
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                
                MetricGaugeView(progress: min(1.0, 
                                              totalMiles / Double(goals.weeklyMileageGoal)),
                                total: totalMiles.prettyString,
                                metric: NSLocalizedString("miles", comment: "miles"))
                .frame(height: geo.size.height * 0.9)
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
