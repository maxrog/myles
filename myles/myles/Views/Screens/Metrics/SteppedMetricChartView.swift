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
    
    @State private var annotationString: String?
    @State private var tappedPlot: CGPoint?
    @State private var selectedRuns: [MylesRun] = []
    
    // TODO i think this is considering Sun-Sat as a week or something? Try getting it to be Monday
    private func generateBarMark(for run: MylesRun) -> BarMark {
        BarMark(x: .value("Label", run.endTime, unit: .weekOfMonth),
                y: .value("Value", run.distance))
    }
    
    var body: some View {
        let focusedRuns = health.focusedRunsFromPast(weekCount: numberOfWeeks)
        ZStack {
            Chart(focusedRuns) { run in
                generateBarMark(for: run)
                    .foregroundStyle(selectedRuns.contains(run) ? Color.primary : run.colorForWorkout)
            }
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    ZStack(alignment: .top) {
                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .onTapGesture { location in
                                updateSelectedState(at: location,
                                                    proxy: proxy,
                                                    geometry: geometry,
                                                    focusedRuns: focusedRuns)
                            }
                    }
                }
            }
            if let annotationString = annotationString, let tappedPlot = tappedPlot {
                Text(annotationString)
                    .fixedSize()
                    .padding(8)
                    .transition(.opacity)
                    .background(in: RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .foregroundStyle(Color.primary)
                    .position(tappedPlot)
                    .zIndex(1)
            }
        }
    }
    
    private func updateSelectedState(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy, focusedRuns: [MylesRun]) {
        guard let plotFrame = proxy.plotFrame else { return }
        let xPosition = location.x - geometry[plotFrame].origin.x
        let yPosition = location.y - geometry[plotFrame].origin.y
        var matchingRuns: [MylesRun] = []
        guard let state: Date = proxy.value(atX: xPosition) else { return }
        matchingRuns = focusedRuns.filter( { $0.endTime.isInSameWeek(as: state) })
        self.selectedRuns = matchingRuns

        let totalMiles = matchingRuns.compactMap({ $0.distance }).reduce(0, +)
        if totalMiles > 0 {
            self.annotationString = "\(totalMiles.prettyString) mi"
        }
        withAnimation(.easeIn(duration: 0.5)) {
            self.tappedPlot = CGPoint(x: xPosition, y: yPosition)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            withAnimation(.easeOut(duration: 1.0)) {
                self.annotationString = nil
                self.tappedPlot = nil
                self.selectedRuns = []
            }
        }
    }
}
