//
//  MapView2.swift
//  CanninLennin
//
//  Created by Camilo Montero on 2025-10-28.
//

import SwiftUI
import MapKit

struct MapView2: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45.52, longitude: -73.74),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    
    private let streets: [Street] = loadStreets()
    
    var body: some View {
        Map {
            // Loop through each street and draw a polyline
            ForEach(streets.indices, id: \.self) { index in
                let street = streets[index]
                MapPolyline(coordinates: street.coordinates)
                    .stroke(.red, lineWidth: 5)
            }
        }
        .mapStyle(.standard)
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .ignoresSafeArea()
    }
}

#Preview {
    MapView2()
}
