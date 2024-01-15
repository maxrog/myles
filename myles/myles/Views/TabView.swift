//
//  TabView.swift
//  myles
//
//  Created by Max Rogers on 12/8/23.
//

import SwiftUI

// TODO figure out how to display empty activity view if health permission granted but no workouts found

struct TabNavigationView: View {
    
    @EnvironmentObject var theme: ThemeManager
    @Environment(HealthManager.self) var health
    
    @State private var viewModel = TabViewModel()
    
    @State var healthPermissionGranted = true
    
    var body: some View {
        Group {
            if !health.runs.isEmpty {
                TabView(selection: $viewModel.selectedTabIndex) {
                    ActivityView()
                        .tabItem {
                            Image(systemName: "figure.run.square.stack.fill")
                        }
                        .tag(Tabs.activity.rawValue)
                    MetricsView()
                        .tabItem {
                            Image(systemName: "chart.bar.fill")
                        }
                        .tag(Tabs.metrics.rawValue)
                    SettingsView()
                        .tabItem {
                            Image(systemName: "gearshape.fill")
                        }
                        .tag(Tabs.settings.rawValue)
                }
                .accentColor(theme.accentColor)
            } else if healthPermissionGranted {
                SplashView()
            } else {
                EmptyActivityView()
            }
        }
        .task {
            // TODO look into diff of task vs onAppear?
            guard await health.requestPermission() else {
                healthPermissionGranted = false
                return
            }
            await health.processWorkouts()
        }
    }
}

#Preview {
    TabNavigationView()
}
