//
//  CombinedMetricsWidgetView.swift
//  MylesWidgetExtension
//
//  Created by Max Rogers on 5/25/24.
//

import SwiftUI

/// A large widget designed to show both running metrics + daily steps
struct CombinedMetricsWidgetView: View {
    
    let entry: MetricEntry
    let geometry: GeometryProxy
    
    var body: some View {
        VStack {
            Spacer()
            StepsGoalWidgetView(entry: entry, geometry: geometry)
                .padding(.bottom, 16)
            ChartMetricWidgetView(entry: entry, geometry: geometry)
            Spacer()
        }
    }
}
