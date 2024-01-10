//
//  RecapViewModel.swift
//  myles
//
//  Created by Max Rogers on 12/21/23.
//

import SwiftUI
import Observation

@MainActor
@Observable
class RecapViewModel {
    
    let health: HealthManager
    
    /// The run to display recap metrics
    let run: MylesRun
    
    /// Whether the map was attempted to load and failed, indicating indoor workout
    var expanded: Bool
    
    /// Whether to show the map on expansion
    var showMap: Bool
    
    /// Whether to show shoe picker
    var displayShoePicker: Bool = false
    
    init(health: HealthManager, run: MylesRun, expanded: Bool = false, showMap: Bool = false) {
        self.health = health
        self.run = run
        self.expanded = expanded
        self.showMap = showMap
    }
    
    func downloadMap() async {
        
        await processSplits()
        
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
    
    func processSplits() async {
        Task {
            let splits = await health.calculateMileSplits(startTime: run.startTime, endTime: run.endTime)
            withAnimation {
                run.mileSplits = splits
            }
        }
    }
}
