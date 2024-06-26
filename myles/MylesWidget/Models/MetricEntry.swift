//
//  MetricEntry.swift
//  myles
//
//  Created by Max Rogers on 2/4/24.
//

import WidgetKit

/// Widget timeline entry for displaying metrics about a group of runs
struct MetricEntry: TimelineEntry {
    /// Timeline date
    let date: Date
    /// Runs to show data from
    let focusedRuns: [MylesRun]
    /// Primary Filter
    let primaryFilter: MetricsPrimaryFilterType
    /// Span Filter
    let spanFilter: MetricsSpanFilterType
    /// Today's Steps
    let todaySteps: Double
}
