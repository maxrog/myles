//
//  DailyView.swift
//  myles
//
//  Created by Max Rogers on 5/27/24.
//

import SwiftUI

/*
 TODO last nights sleep/weather for today/tomorrow + any activities from today + gpt api suggested next workout? (look into privacy implications)
 */

/// A today view that displays views for goals etc
struct TodayView: View {
    
    @Environment(HealthManager.self) var health
    @EnvironmentObject var goals: GoalsManager
    
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
                            .listRowInsets(EdgeInsets())
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
                            .listRowInsets(EdgeInsets())
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
                }
                .refreshable { await health.processWorkouts() }
                .navigationTitle("Today")
            }
        }
    }
}

#Preview {
    TodayView()
}
