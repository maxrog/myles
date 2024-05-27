//
//  TabView.swift
//  myles
//
//  Created by Max Rogers on 12/8/23.
//

import SwiftUI

struct TabNavigationView: View {
    
    @EnvironmentObject var theme: ThemeManager
    @Environment(HealthManager.self) var health
    
    @State private var viewModel = TabViewModel()
    
    @State private var splashComplete = false
    
    var body: some View {
        Group {
            if !splashComplete {
                SplashView(splashComplete: $splashComplete)
            } else if !health.runs.isEmpty {
                TabView(selection: $viewModel.selectedTabIndex) {
                    ActivityView()
                        .tabItem {
                            Image(systemName: "figure.run.square.stack.fill")
                        }
                        .tag(Tabs.activity.rawValue)
                    /*
                     TODO have a "Today" View that can show step/run goal + last nights sleep/weather for today/tomorrow + any activities from today + gpt api suggested next workout? (look into privacy implications)
                     */
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
            } else {
                EmptyActivityView()
            }
        }
    }
}

#Preview {
    TabNavigationView()
}
