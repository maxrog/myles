//
//  MetricsView.swift
//  myles
//
//  Created by Max Rogers on 1/13/24.
//

import SwiftUI
import Charts

/*
 // TODO look into custom view for refreshable -- have little beating heart
 TODO - support average somehow for month/year
 TODO - view visibility / re ordering manager to customize stats shown etc
 */

/// View that displays filterable metrics
struct MetricsView: View {
    
    @Environment(HealthManager.self) var health
    
    var body: some View {
        GeometryReader { geo in
            NavigationStack {
                List {
                    MetricsChartGroupView()
                    LastLongRunView()
                }
                .refreshable { await health.processWorkouts() }
                .navigationTitle("My Miles")
            }
        }
    }
}

#Preview {
    MetricsView()
}
