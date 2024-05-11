//
//  MylesWidget.swift
//  MylesWidget
//
//  Created by Max Rogers on 1/24/24.
//

import WidgetKit
import SwiftUI

/*
 TODO IntentConfiguration for filter types
 TODO lock screen widget
 */

/// A widget for displaying metrics
struct MetricWidget: Widget {
    
    let kind: String = "MetricWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MetricWidgetTimelineProvider()) { entry in
            MetricWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
            // TODO support daily steps widget
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName("Metrics")
        .description("Track your week.")
    }
}

#Preview(as: .systemSmall) {
    MetricWidget()
} timeline: {
    MetricEntry(date: .now, 
                focusedRuns: [MylesRun.testRun],
                primaryFilter: .distance,
                spanFilter: .week)
}
