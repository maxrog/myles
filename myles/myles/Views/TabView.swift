//
//  TabView.swift
//  myles
//
//  Created by Max Rogers on 12/8/23.
//

import SwiftUI

struct TabNavigationView: View {
    
    @EnvironmentObject var theme: ThemeManager
    @State private var viewModel = TabViewModel()
    
    var body: some View {
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
    }
}

#Preview {
    TabNavigationView()
}
