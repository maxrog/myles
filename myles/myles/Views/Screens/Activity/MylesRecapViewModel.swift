//
//  MylesRecapViewModel.swift
//  myles
//
//  Created by Max Rogers on 12/21/23.
//

import SwiftUI

@MainActor
class MylesRecapViewModel: ObservableObject {
    
    @Published var health = HealthStoreManager.shared
    
    /// The run to display recap metrics
    @Published var run: MylesRun
    
    /// Whether the map was attempted to load and failed, indicating indoor workout
    @Published var expanded: Bool
    
    /// Whether to show the map on expansion
    var showMap: Bool
    
    init(health: HealthStoreManager = HealthStoreManager.shared, run: MylesRun, expanded: Bool = false, showMap: Bool = false) {
        self.health = health
        self.run = run
        self.expanded = expanded
        self.showMap = showMap
    }
    
    func downloadMap() async {
        
        guard run.environment == .outdoor else {
            withAnimation {
                showMap = false
                expanded.toggle()
            }
            return
        }
        
        guard !run.hasLocationData else {
            withAnimation {
                expanded.toggle()
            }
            return
        }
        
        Task {
            let mapAvailable = await health.loadMapData(for: run)
            withAnimation {
                showMap = mapAvailable
                expanded.toggle()
            }
        }
    }
}
