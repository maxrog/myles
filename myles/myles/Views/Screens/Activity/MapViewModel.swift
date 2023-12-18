//
//  MapViewModel.swift
//  myles
//
//  Created by Max Rogers on 12/18/23.
//

import SwiftUI
import MapKit

/// View model to manage map state
class MapViewModel: ObservableObject {
    
    /// The run to display in the map
    @Published var run: MylesRun
    /// Whether user can pan the map (disabled until they interact)
    @Published var panEnabled: Bool
    /// The map's current position
    @Published var position: MapCameraPosition
    
    init(run: MylesRun, panEnabled: Bool = false, position: MapCameraPosition = .automatic) {
        self.run = run
        self.panEnabled = panEnabled
        self.position = position
    }
    
}
