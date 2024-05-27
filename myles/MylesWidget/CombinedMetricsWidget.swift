//
//  CombinedMetricsWidget.swift
//  myles
//
//  Created by Max Rogers on 5/26/24.
//

import SwiftUI
import WidgetKit


/// A widget for displaying combined steps and runs
struct CombinedMetricsWidget: Widget {
    
    let kind: String = "CombinedMetricsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MetricWidgetTimelineProvider()) { entry in
            GeometryReader { geo in
                CombinedMetricsWidgetView(entry: entry, geometry: geo)
                    .containerBackground(.fill.tertiary, for: .widget)
            }
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("My Miles")
        .description("Track your goals.")
    }
}
