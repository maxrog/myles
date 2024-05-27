//
//  StepsWidget.swift
//  MylesWidgetExtension
//
//  Created by Max Rogers on 5/25/24.
//

import WidgetKit
import SwiftUI

/*
 TODO lock screen widget
 */

/// A widget for displaying metrics
struct StepsWidget: Widget {
    
    let kind: String = "StepsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MetricWidgetTimelineProvider()) { entry in
            StepsWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName("My Miles")
        .description("Track your goals.")
    }
}

#Preview(as: .systemSmall) {
    MetricWidget()
} timeline: {
    MetricEntry(date: .now,
                focusedRuns: [MylesRun.testRun],
                primaryFilter: .distance,
                spanFilter: .week,
                dailySteps: 5000)
}
