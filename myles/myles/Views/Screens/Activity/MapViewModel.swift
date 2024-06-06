//
//  MapViewModel.swift
//  myles
//
//  Created by Max Rogers on 12/18/23.
//

import SwiftUI
import MapKit
import Observation

/// View model to manage map state
@Observable
class MapViewModel {

    /// The run to display in the map
    let run: MylesRun
    /// Whether user can pan the map (disabled until they interact)
    var panEnabled: Bool
    /// The map's current position
    var position: MapCameraPosition

    init(run: MylesRun, panEnabled: Bool = false, position: MapCameraPosition = .automatic) {
        self.run = run
        self.panEnabled = panEnabled
        self.position = position
    }

}
