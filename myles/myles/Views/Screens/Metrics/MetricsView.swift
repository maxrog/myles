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
 TODO - XTraining stats (toggleable in settings)
 // TODO look into custom view for refreshable -- have little beating heart
 TODO - support average somehow for month/year
 TODO - refactor out views
 */

/// View that displays filterable metrics
struct MetricsView: View {
    
    @Environment(HealthManager.self) var health
    @EnvironmentObject var goals: GoalsManager
    
    @AppStorage("com.marfodub.myles.MetricsWeekCountFilter") var steppedChartWeekCount: Int = 1
    @State var steppedChartHeader = ""
    private func updateSteppedHeader() {
        steppedChartHeader = "\(Int(health.runsTotalDistance(health.focusedRunsFromPast(weekCount: steppedChartWeekCount)))) mi\nLast \(steppedChartWeekCount > 1 ? "\(steppedChartWeekCount) Weeks" : "Week")"
    }

    
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
        GeometryReader { geo in
            NavigationStack {
                List {
                    if goals.dailyStepGoal > 0 {
                        let currentSteps = health.dailySteps
                        let goal = goals.dailyStepGoal
                        Section {
                            MetricsProgressBarView(currentValue: Int(currentSteps),
                                                   totalValue: goal,
                                                   descriptionText: "Daily Goal: \(goal) steps")
                            .padding()
                        }
                        .listRowBackground(Color.clear)
                    }
                    
                    if goals.weeklyMileageGoal > 0 {
                        let weeklyRuns = health.focusedRuns(for: .week)
                        let totalMiles = health.runsTotalDistance(weeklyRuns)
                        let gaugeSize = min(115, geo.size.height / 6)
                        Section {
                            HStack {
                                Spacer()
                                MetricGaugeView(progress: min(1.0,
                                                              totalMiles / Double(goals.weeklyMileageGoal)),
                                                total: totalMiles.prettyString,
                                                goal: nil,
                                                metric: NSLocalizedString("miles", comment: "miles"))
                                .frame(width: gaugeSize, height: gaugeSize)
                                .padding(12)
                                Spacer()
                            }
                        } header: {
                            HStack {
                                Spacer()
                                Text("Weekly Goal: \(goals.weeklyMileageGoal) miles")
                                    .font(.custom("norwester", size: 16))
                                Spacer()
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                    
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
                .refreshable { await health.processWorkouts() }
                .navigationTitle("My Miles")
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
}

#Preview {
    MetricsView()
}
