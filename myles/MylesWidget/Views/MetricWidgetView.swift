//
//  MetricWidgetView.swift
//  myles
//
//  Created by Max Rogers on 1/24/24.
//

import SwiftUI
import WidgetKit

// TODO make a cache of runs from this week (cleared on new week), if have runs from this week but entry has none, use ones from cache -- can prob do this in timeline provider
// TODO custom font

/// A widget view for displaying metrics
struct MetricWidgetView: View {
    
    @Environment(\.widgetFamily) var family
    let entry: MetricEntry
    
    var body: some View {
        GeometryReader { geo in
            switch family {
            case .systemSmall:
                CompactMetricWidgetView(entry: entry, geometry: geo)
            default:
                ChartMetricWidgetView(entry: entry, geometry: geo)
            }
        }
    }
}

#Preview {
    MetricWidgetView(entry: MetricEntry(date: .now,
                                             focusedRuns: [MylesRun.testRun], 
                                             primaryFilter: .distance,
                                             spanFilter: .week))
}
