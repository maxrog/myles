//
//  ActivityView.swift
//  myles
//
//  Created by Max Rogers on 12/12/23.
//

import SwiftUI
import HealthKit

/*
 TODO refreshable modifier (pull to refresh)
 */

struct ActivityView: View {
    
    @Environment(HealthManager.self) var health

    @State var healthPermissionGranted = true
    @State var streakBounce = 0
    
    var body: some View {
        
        let runs = health.runs
        
        NavigationStack {
            Group {
                if !runs.isEmpty {
                    List {
                        ForEach(runs) { run in
                            Section {
                                RecapView(viewModel: RecapViewModel(health: health,
                                                                              run: run,
                                                                              expanded: run.hasLocationData,
                                                                              showMap: run.hasLocationData))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .listRowInsets(EdgeInsets())
                            } header: {
                                RecapHeaderView(run: run)
                            }
                        }
                    }
                } else if healthPermissionGranted {
                    ProgressView()
                } else {
                    EmptyActivityView()
                }
            }
            .toolbar(health.streakCount() == 0 ? .hidden : .visible)
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                let streak = health.streakCount()
                if streak > 0 {
                    ToolbarItem(placement: .topBarTrailing) {
                        StreakView(streakCount: streak)
                            .symbolEffect(.bounce, value: streakBounce)
                            .onTapGesture {
                                streakBounce += 1
                                // TODO display something explaining streak?
                            }
                    }
                }
            }
        }
        .task {
            // TODO look into diff of task vs onAppear?
            guard await health.requestPermission() else {
                healthPermissionGranted = false
                return
            }
            
            // TODO this gets called everytime the screen appears / state object changes - should only happen on pull to refresh
            await health.processWorkouts()
        }
    }
}

#Preview {
    ActivityView()
}
