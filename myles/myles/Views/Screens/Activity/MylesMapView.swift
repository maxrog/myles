//
//  MylesMapView.swift
//  myles
//
//  Created by Max Rogers on 12/16/23.
//

import SwiftUI
import MapKit

/// A Map view that displays a polyline of the user's run
/// We disable panning until the user interacts with the map, to avoid scrolling conflicts
struct MylesMapView: View {
    
    @EnvironmentObject var theme: ThemeManager
    
    @State var run: MylesRun
    
    @State var panEnabled: Bool = false
    @State private var position: MapCameraPosition = .automatic
        
    /// The enabled interactionModes which change after user adjusts the map for first time
    private var interactionModes: MapInteractionModes {
        panEnabled ? .all : [.pitch, .rotate, .zoom]
    }
    
    /// All CLLocationCoordinate2D objects from the run
    private var coordinates: [CLLocationCoordinate2D] {
        (run.locationPoints ?? []).map({ $0.coordinate })
    }

    /// The bounds of the run's coordinates
    var coordinateBounds: MKMapRect {
        coordinates.map { MKMapRect(origin: .init($0), size: .init(width: 1, height: 1)) }
        .reduce(MKMapRect.null) { $0.union($1) }
    }
    
    var body: some View {
        Map(
            position: $position,
            bounds: MapCameraBounds(centerCoordinateBounds: coordinateBounds, minimumDistance: 0, maximumDistance: 50000),
            interactionModes: interactionModes) {
                Annotation("\(run.startTime.shortTimeOfDayDateFormat)", coordinate: coordinates.first ?? CLLocationCoordinate2D()) {
                    Image(systemName: "flag.checkered.circle.fill")
                        .foregroundStyle(.green)
                        .background(.white)
                        .clipShape(Circle())
                }
                Annotation("\(run.endTime.shortTimeOfDayDateFormat)", coordinate: coordinates.last ?? CLLocationCoordinate2D()) {
                    Image(systemName: "flag.checkered.circle.fill")
                        .foregroundStyle(.red)
                        .background(.white)
                        .clipShape(Circle())
                }
            
            MapPolyline(coordinates: coordinates)
                    .stroke(theme.accentColor, lineWidth: 0.5)
            }
            .onChange(of: position) {
                panEnabled = position.positionedByUser
            }
            .onAppear() {
                position = .rect(coordinateBounds)
            }
        // TODO put map style in settings
            .mapStyle(.standard)
    }
}

// TODO mock up a test run to put into previews that need a run
//#Preview {
//    MapView()
//}
