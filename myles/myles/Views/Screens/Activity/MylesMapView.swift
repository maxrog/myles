//
//  MylesMapView.swift
//  myles
//
//  Created by Max Rogers on 12/16/23.
//

import SwiftUI
import MapKit

struct MylesMapView: View {
    
    @EnvironmentObject var theme: ThemeManager
    
    @State var run: MylesRun
    
    @State var panEnabled: Bool = false
    @State private var position: MapCameraPosition = .automatic
        
    private var interactionModes: MapInteractionModes {
        panEnabled ? .all : [.pitch, .rotate, .zoom]
    }
    private var coordinates: [CLLocationCoordinate2D] {
        (run.locationPoints ?? []).map({ $0.coordinate })
    }
    private var centerCoordinate: CLLocationCoordinate2D {
        let coords = coordinates
        guard coords.count > 0 else { return CLLocationCoordinate2D() }
        let midIndex = coords.count / 2
        return coords[midIndex]
    }
    var coordinateBounds: MKMapRect {
        coordinates.map { MKMapRect(origin: .init($0), size: .init(width: 1, height: 1)) }
        .reduce(MKMapRect.null) { $0.union($1) }
    }
    
    var body: some View {
        Map(
            position: $position,
            bounds: MapCameraBounds(centerCoordinateBounds: coordinateBounds, maximumDistance: 50000),
            interactionModes: interactionModes) {
            Annotation("\(run.startTime.shortTimeOfDayDateFormat)", coordinate: coordinates.first ?? CLLocationCoordinate2D()) {
                Image(systemName: "flag.checkered")
                                    .foregroundStyle(.black)
                                    .background(.green)
                                    .frame(width: 8, height: 8)
            }
            Annotation("\(run.endTime.shortTimeOfDayDateFormat)", coordinate: coordinates.last ?? CLLocationCoordinate2D()) {
                Image(systemName: "flag.checkered")
                                    .foregroundStyle(.black)
                                    .background(.red)
                                    .frame(width: 8, height: 8)
            }
            
            MapPolyline(coordinates: coordinates)
                .stroke(theme.accentColor, lineWidth: 2)
  
                Annotation("Distance", coordinate: centerCoordinate) {
                    Text("\(run.distance)")
                }
            }
            .onChange(of: position) {
                panEnabled = position.positionedByUser
            }
        // TODO put map style in settings
            .mapStyle(.hybrid)
    }
}

// TODO mock up a test run to put into previews that need a run
//#Preview {
//    MapView()
//}
