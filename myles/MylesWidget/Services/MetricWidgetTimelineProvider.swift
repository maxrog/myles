//
//  MetricWidgetTimelineProvider.swift
//  myles
//
//  Created by Max Rogers on 2/4/24.
//

import WidgetKit

/*
 TODO sometimes getting 0 miles for some reason
 */

/// Provides timelines of how to bundle data to be shown and when to refresh or cycle through items
struct MetricWidgetTimelineProvider: TimelineProvider {
    
    /// placeholder while loading (auto redacts so data doesn't matter
    func placeholder(in context: Context) -> MetricEntry {
        MetricEntry(date: .now,
                    focusedRuns: MylesRun.widgetSnapshotRuns(),
                    primaryFilter: .distance,
                    spanFilter: .week)
    }
    
    /// snapshot to display while user is in
    func getSnapshot(in context: Context, completion: @escaping (MetricEntry) -> ()) {
        getTimeline(in: context) { timeline in
            completion(timeline.entries.first ?? MetricEntry(date: .now,
                                                             focusedRuns: MylesRun.widgetSnapshotRuns(),
                                                             primaryFilter: .distance,
                                                             spanFilter: .week))
        }
    }
    
    /// gather data and provide timeline
    func getTimeline(in context: Context, completion: @escaping (Timeline<MetricEntry>) -> ()) {
        Task {
            let currentDate = Date()
            let refreshMinuteGranuity = 45
            let refreshDate = Calendar.current.date(
                byAdding: .minute,
                value: refreshMinuteGranuity,
                to: currentDate
            ) ?? currentDate.addingTimeInterval(2700)
            
            let health = HealthManager()
            await health.processWorkouts(limit: 20)
            let primaryFilter = MetricsPrimaryFilterType.distance
            let spanFilter = MetricsSpanFilterType.week
            let runs = health.focusedRuns(for: spanFilter)
            let timeline = Timeline(entries: [MetricEntry(date: .now,
                                                          focusedRuns: runs,
                                                          primaryFilter: primaryFilter,
                                                          spanFilter: spanFilter)],
                                    policy: .after(refreshDate))
            completion(timeline)
        }
    }
    
}
