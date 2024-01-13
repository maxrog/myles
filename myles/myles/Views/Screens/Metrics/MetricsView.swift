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
 */

struct MetricsView: View {
    
    @Environment(HealthManager.self) var health
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack {
                        Chart(health.currentWeekRuns()) { run in
                            BarMark(x: .value("Label", run.endTime.shortDayOfWeekDateFormat),
                                    y: .value("Value", run.distance))
                        }
                        .chartXAxisLabel(position: .top, alignment: .center, spacing: 8) {
                            Text("Distance")
                                .font(.custom("norwester", size: 20))
                        }
                        Chart(health.currentWeekRuns()) { run in
                            BarMark(x: .value("Label", run.endTime.shortDayOfWeekDateFormat),
                                    y: .value("Value", run.duration))
                        }
                        .chartXAxisLabel(position: .top, alignment: .center, spacing: 8) {
                            Text("Duration")
                                .font(.custom("norwester", size: 20))
                        }
                    }
                } header: {
                    Text("Current Week")
                        .font(.custom("norwester", size: 16))
                }
            }
            .navigationTitle("My Miles")
        }
    }
}

#Preview {
    MetricsView()
}
