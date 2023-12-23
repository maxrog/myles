//
//  ActivityView.swift
//  myles
//
//  Created by Max Rogers on 12/12/23.
//

import SwiftUI
import HealthKit

// TODO Loading animation / at least activity indicator

struct ActivityView: View {
    
    @StateObject private var health = HealthStoreManager.shared
    @StateObject private var metrics = MetricsManager.shared
    @State var healthPermissionGranted = true
    
    var body: some View {
        
        let runs = health.runs
        
        NavigationStack {
            Group {
                if !runs.isEmpty {
                    List {
                        ForEach(runs) { run in
                            Section {
                                MylesRecapView(viewModel: MylesRecapViewModel(run: run, expanded: run.hasLocationData, showMap: run.hasLocationData))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .listRowInsets(EdgeInsets())
                            } header: {
                                MylesRecapHeaderView(run: run)
                            }
                        }
                    }
                } else if healthPermissionGranted {
                    Text("Loading")
                        .frame(maxWidth: .infinity)
                } else {
                    EmptyActivityView()
                }
            }
            .toolbar(metrics.streakCount() == 0 ? .hidden : .visible)
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    MylesStreakView(streakCount: metrics.streakCount())
                }
            }
        }
        .task {
            // TODO look into diff of task vs onAppear?
            guard await health.requestPermission() else {
                healthPermissionGranted = false
                return
            }
            
            // TODO this gets called everytime the screen appears - should only happen on pull to refresh
            await health.processWorkouts()
        }
    }
}

#Preview {
    ActivityView()
}
