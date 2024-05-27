//
//  MetricsChartGroupView.swift
//  myles
//
//  Created by Max Rogers on 5/27/24.
//

import SwiftUI

/// A group of charts that display workout metrics
struct MetricsChartGroupView: View {
    
    @Environment(HealthManager.self) var health
    
    @State private var primaryFilter = MetricsPrimaryFilterType.distance
    @State private var spanFilter = MetricsSpanFilterType.week
    
    @State private var focusedRuns: [MylesRun] = []
    
    @AppStorage("com.marfodub.myles.MetricsWeekCountFilter") var steppedChartWeekCount: Int = 1
    @State private var steppedChartHeader = ""
    private func updateSteppedHeader() {
        steppedChartHeader = "\(Int(health.runsTotalDistance(health.focusedRunsFromPast(weekCount: steppedChartWeekCount)))) mi\nLast \(steppedChartWeekCount * 7) days"
    }
    
    
    var averageUnit: String {
        var averageUnit = ""
        switch spanFilter {
        case .week:
            averageUnit = "/day"
        case .month:
            averageUnit = "/week"
        case .year:
            averageUnit = "/month"
        }
        return averageUnit
    }
    
    init() {
        if let segmentedFont = UIFont(name: "norwester", size: 18) {
            UISegmentedControl.appearance().setTitleTextAttributes([.font : segmentedFont], for: .normal)
        }
    }
    
    var body: some View {
        Group {
            // TODO scrollable charts
            Section {
                VStack {
                    Picker("", selection: $primaryFilter.animation()) {
                        Text("distance").tag(MetricsPrimaryFilterType.distance)
                        Text("duration").tag(MetricsPrimaryFilterType.duration)
                    }
                    .pickerStyle(.segmented)
                    
                    MetricChartView(focusedRuns: focusedRuns, primaryFilter: primaryFilter, spanFilter: spanFilter)
                    
                    Picker("", selection: $spanFilter.animation()) {
                        Text("week").tag(MetricsSpanFilterType.week)
                        Text("month").tag(MetricsSpanFilterType.month)
                        Text("year").tag(MetricsSpanFilterType.year)
                    }
                    .pickerStyle(.segmented)
                }
            } header: {
                switch primaryFilter {
                case .distance:
                    if health.runsTotalDistance(focusedRuns) > 0 {
                        Text("Total: \(health.runsTotalDistance(focusedRuns).prettyString)")
                            .font(.custom("norwester", size: 16))
                    }
                case .duration:
                    if health.runsTotalDistance(focusedRuns) > 0 {
                        Text("Total: \(health.runsTotalDuration(focusedRuns).prettyTimeString)")
                            .font(.custom("norwester", size: 16))
                    }
                }
            } footer: {
                let legendViews = MetricChartView.legend(for: focusedRuns,
                                                         displayingDistance: primaryFilter == .distance)
                HStack {
                    Spacer()
                    ForEach(0..<legendViews.count, id: \.self) { index in
                        legendViews[index]
                    }
                }
            }
            
            Section {
                SteppedMetricChartView(numberOfWeeks: $steppedChartWeekCount)
            } header: {
                Stepper(onIncrement: {
                    withAnimation {
                        steppedChartWeekCount = steppedChartWeekCount + 1
                        updateSteppedHeader()
                    }
                }, onDecrement: {
                    guard steppedChartWeekCount > 1 else { return }
                    withAnimation {
                        steppedChartWeekCount = steppedChartWeekCount - 1
                        updateSteppedHeader()
                    }
                }, label: {
                    Text(steppedChartHeader)
                        .font(.custom("norwester", size: 16))
                })
            } footer: {
                let legendViews = MetricChartView.legend(for: health.focusedRunsFromPast(weekCount: steppedChartWeekCount),
                                                         displayingDistance: true)
                HStack {
                    Spacer()
                    ForEach(0..<legendViews.count, id: \.self) { index in
                        legendViews[index]
                    }
                }
            }
        }
        .onAppear {
            focusedRuns = health.focusedRuns(for: spanFilter)
            updateSteppedHeader()
        }
        .onChange(of: health.runs) {
            focusedRuns = health.focusedRuns(for: spanFilter)
        }
        .onChange(of: spanFilter) {
            focusedRuns = health.focusedRuns(for: spanFilter)
        }
    }
}

#Preview {
    MetricsChartSectionView()
}
