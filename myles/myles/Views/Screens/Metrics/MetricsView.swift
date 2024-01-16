//
//  MetricsView.swift
//  myles
//
//  Created by Max Rogers on 1/13/24.
//

import SwiftUI
import Charts

/*
 TODO - Gauge view for goals
 TODO - refreshable modifier (pull to refresh will call health.processWorkouts)
 TODO - XTraining stats (toggleable in settings)
 */

enum MetricsPrimaryFilterType: Int {
    case distance, duration
}
enum MetricsSpanFilterType: Int {
    case week, month, year
}

/// View that displays filterable metrics 
struct MetricsView: View {
    
    @Environment(HealthManager.self) var health
    
    @State var primaryFilter = MetricsPrimaryFilterType.distance
    @State var spanFilter = MetricsSpanFilterType.week
    
    @State var focusedRuns: [MylesRun] = []
    
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
        NavigationStack {
            List {
                Section {
                    VStack {
                        Picker("", selection: $primaryFilter) {
                            Text("distance").tag(MetricsPrimaryFilterType.distance)
                            Text("duration").tag(MetricsPrimaryFilterType.duration)
                        }
                        .pickerStyle(.segmented)
                        
                        MetricChartView(focusedRuns: focusedRuns, primaryFilter: primaryFilter, spanFilter: spanFilter)
                        
                        Picker("", selection: $spanFilter) {
                            Text("week").tag(MetricsSpanFilterType.week)
                            Text("month").tag(MetricsSpanFilterType.month)
                            Text("year").tag(MetricsSpanFilterType.year)
                        }
                        .pickerStyle(.segmented)
                    }
                } header: {
                    let averageDenominator =  health.elapsedDaysForSpan(spanFilter) / health.groupedDayCountForSpan(spanFilter)
                    HStack {
                        switch primaryFilter {
                        case .distance:
                            Text("Total: \(health.runsTotalDistance(focusedRuns).prettyString)")
                                .font(.custom("norwester", size: 16))
                            Spacer()
                            Text("Avg: \((health.runsTotalDistance(focusedRuns) / averageDenominator).prettyString)\(averageUnit)")
                                .font(.custom("norwester", size: 16))
                        case .duration:
                            Text("Total: \(health.runsTotalDuration(focusedRuns).prettyTimeString)")
                                .font(.custom("norwester", size: 16))
                            Spacer()
                            Text("Avg: \((health.runsTotalDuration(focusedRuns) / averageDenominator).prettyTimeString)\(averageUnit)")
                                .font(.custom("norwester", size: 16))
                        }
                    }
                }
            }
            .refreshable { await health.processWorkouts() }
            .navigationTitle("My Miles")
        }
        .onAppear {
            focusedRuns = health.focusedRuns(for: spanFilter)
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
    MetricsView()
}
