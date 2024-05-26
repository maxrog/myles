//
//  StepsWidgetView.swift
//  MylesWidgetExtension
//
//  Created by Max Rogers on 5/25/24.
//

import SwiftUI

/// A widget view for displaying metrics
struct StepsWidgetView: View {
    
    @Environment(\.widgetFamily) var family
    let entry: MetricEntry
    
    var body: some View {
        GeometryReader { geo in
            switch family {
            case .systemSmall:
                CompactStepsGoalWidgetView(entry: entry, geometry: geo)
            default:
                StepsGoalWidgetView(entry: entry, geometry: geo)
            }
        }
    }
}

#Preview {
    StepsWidgetView(entry: MetricEntry(date: .now,
                                        focusedRuns: [MylesRun.testRun],
                                        primaryFilter: .distance,
                                        spanFilter: .week,
                                        dailySteps: 5000))
}
