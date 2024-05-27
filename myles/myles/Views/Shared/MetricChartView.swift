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
    
    @State private var annotationString: String?
    @State private var tappedPlot: CGPoint?
    
    let focusedRuns: [MylesRun]
    let primaryFilter: MetricsPrimaryFilterType
    let spanFilter: MetricsSpanFilterType
    let formatter = DateFormatter()
    
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
        ZStack {
            Chart(focusedRuns) { run in
                generateBarMark(for: run)
                    .foregroundStyle(run.colorForWorkout)
            }
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    ZStack(alignment: .top) {
                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .onTapGesture { location in
                                updateSelectedState(at: location, proxy: proxy, geometry: geometry)
                            }
                    }
                }
            }
            if let annotationString = annotationString, let tappedPlot = tappedPlot {
                Text(annotationString)
                    .fixedSize()
                    .padding(6)
                    .transition(.opacity)
                    .background(in: RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .foregroundStyle(Color.primary)
                    .position(tappedPlot)
                    .zIndex(1)
            }
        }
    }
    
    private func updateSelectedState(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        guard let plotFrame = proxy.plotFrame else { return }
        let xPosition = location.x - geometry[plotFrame].origin.x
        let yPosition = location.y - geometry[plotFrame].origin.y
        switch spanFilter {
        case .week:
            guard let state: String = proxy.value(atX: xPosition) else { return }
            formatter.dateFormat = "E"
            if let date = formatter.date(from: state) {
                let matchingRuns = focusedRuns.filter({
                    date.shortDayOfWeekDateFormat == $0.endTime.shortDayOfWeekDateFormat
                })
                let totalMiles = matchingRuns.compactMap({ $0.distance }).reduce(0, +)
                if totalMiles > 0 {
                    self.annotationString = "\(totalMiles.prettyString) mi"
                }
            }
        case .month:
            guard let state: Date = proxy.value(atX: xPosition) else { return }
            let matchingRuns = focusedRuns.filter( { $0.endTime.isInSameWeek(as: state) })
            let totalMiles = matchingRuns.compactMap({ $0.distance }).reduce(0, +)
            if totalMiles > 0 {
                self.annotationString = "\(totalMiles.prettyString) mi"
            }
        case .year:
            guard let state: String = proxy.value(atX: xPosition) else { return }
            formatter.dateFormat = "MMM"
            if let date = formatter.date(from: state) {
                let matchingRuns = focusedRuns.filter({
                    date.shortMonthOfYearDateFormat == $0.endTime.shortMonthOfYearDateFormat
                })
                let totalMiles = matchingRuns.compactMap({ $0.distance }).reduce(0, +)
                if totalMiles > 0 {
                    self.annotationString = "\(totalMiles.prettyString) mi"
                }
            }
        }
        withAnimation(.easeIn(duration: 0.5)) {
            self.tappedPlot = CGPoint(x: xPosition, y: yPosition)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            withAnimation(.easeOut(duration: 1.0)) {
                self.annotationString = nil
                self.tappedPlot = nil
            }
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
