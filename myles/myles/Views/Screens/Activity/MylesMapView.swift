//
//  MylesMapView.swift
//  myles
//
//  Created by Max Rogers on 12/16/23.
//

import SwiftUI
import MapKit

/// A Map view that displays a polyline of the user's run
/// We disable panning until the user interacts with the map, to avoid scrolling conflicts with container
struct MylesMapView: View {
    
    @EnvironmentObject var theme: ThemeManager
    @StateObject var viewModel: MapViewModel
        
    /// The enabled interactionModes which change after user adjusts the map for first time
    private var interactionModes: MapInteractionModes {
        viewModel.panEnabled ? .all : [.pitch, .rotate, .zoom]
    }
    
    /// All CLLocationCoordinate2D objects from the run
    private var coordinates: [CLLocationCoordinate2D] {
        (viewModel.run.locationPoints ?? []).map({ $0.coordinate })
    }

    /// The bounds of the run's coordinates
    var coordinateBounds: MKMapRect {
        coordinates.map { MKMapRect(origin: .init($0), size: .init(width: 1, height: 1)) }
        .reduce(MKMapRect.null) { $0.union($1) }
    }
    
    var body: some View {
        Map(
            position: $viewModel.position,
            bounds: MapCameraBounds(centerCoordinateBounds: coordinateBounds, minimumDistance: 0, maximumDistance: 50000),
            interactionModes: interactionModes) {
                Annotation("\(viewModel.run.startTime.shortTimeOfDayDateFormat)", coordinate: coordinates.first ?? CLLocationCoordinate2D()) {
                    Image(systemName: "flag.checkered.circle.fill")
                        .foregroundStyle(.green)
                        .background(.white)
                        .clipShape(Circle())
                }
                Annotation("\(viewModel.run.endTime.shortTimeOfDayDateFormat)", coordinate: coordinates.last ?? CLLocationCoordinate2D()) {
                    Image(systemName: "flag.checkered.circle.fill")
                        .foregroundStyle(.red)
                        .background(.white)
                        .clipShape(Circle())
                }
            
            MapPolyline(coordinates: coordinates)
                    .stroke(theme.accentColor, lineWidth: 1.5)
            }
            .onChange(of: viewModel.position) {
                viewModel.panEnabled = viewModel.position.positionedByUser
            }
            .onAppear() {
                viewModel.position = .rect(coordinateBounds)
            }
        // TODO put map style in settings
            .mapStyle(.standard)
    }
}

#Preview {
    MylesMapView(viewModel: MapViewModel(run: MylesRun.testRun))
}
