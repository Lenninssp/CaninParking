//
//  StreetMapView.swift
//  CanninLennin
//
//  Created by Camilo Montero on 2025-10-28.
//

import SwiftUI
import MapKit

struct StreetMapView: UIViewRepresentable {
    let streets: [Street]
    @Binding var selectedStreet: Street?
    
    // resource for base: http://medium.com/@nevinchanyi/mkmapview-in-swiftui-complete-guide-115c4602af8a
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.pointOfInterestFilter = .excludingAll
        mapView.showsUserLocation = false
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        
        for street in streets {
            let polyline = MKPolyline(coordinates: street.coordinates, count: street.coordinates.count)
            polyline.title = street.name
            mapView.addOverlay(polyline)
        }
        
        let rect = mapView.overlays.reduce(MKMapRect.null) { $0.union($1.boundingMapRect) }
        mapView.setVisibleMapRect(rect,
                                  edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50),
                                  animated: false)
        
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleMapTap(_:)))
        mapView.addGestureRecognizer(tap)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        
        if let street = selectedStreet,
           let midCoord = street.coordinates.dropFirst(street.coordinates.count / 2).first {
            let annotation = MKPointAnnotation()
            annotation.title = street.name
            annotation.coordinate = midCoord
            uiView.addAnnotation(annotation)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(streets: streets, selectedStreet: $selectedStreet)
    }
}

extension StreetMapView {
    class Coordinator: NSObject, MKMapViewDelegate {
        let streets: [Street]
        @Binding var selectedStreet: Street?
        
        init(streets: [Street], selectedStreet: Binding<Street?>) {
            self.streets = streets
            _selectedStreet = selectedStreet
        }
        
        private var renderers: [MKPolyline: MKPolylineRenderer] = [:]
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline else { return MKOverlayRenderer() }
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = adjustedLineWidth(for: mapView)
            renderers[polyline] = renderer
            return renderer
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let newWidth = adjustedLineWidth(for: mapView)
            for renderer in renderers.values {
                renderer.lineWidth = newWidth
                renderer.invalidatePath()
            }
        }
        
        private func adjustedLineWidth(for mapView: MKMapView) -> CGFloat {
            let zoomScale = mapView.visibleMapRect.size.width / Double(mapView.bounds.size.width)
            let baseWidth: CGFloat = 3.0
            return max(0.5, min(6.0, baseWidth / CGFloat(zoomScale * 0.00005)))
        }
        
        @objc func handleMapTap(_ gestureRecognizer: UITapGestureRecognizer) {
            guard let mapView = gestureRecognizer.view as? MKMapView else { return }
            let tapPoint = gestureRecognizer.location(in: mapView)
            let tapCoordinate = mapView.convert(tapPoint, toCoordinateFrom: mapView)
            let mapPoint = MKMapPoint(tapCoordinate)
            
            for overlay in mapView.overlays {
                guard let polyline = overlay as? MKPolyline,
                      let renderer = mapView.renderer(for: polyline) as? MKPolylineRenderer else { continue }
                
                let cgPoint = renderer.point(for: mapPoint)
                let hitBox = renderer.path?.copy(
                    strokingWithWidth: renderer.lineWidth * 4,
                    lineCap: .round, lineJoin: .round, miterLimit: 0
                )
                
                if let hitBox = hitBox, hitBox.contains(cgPoint) {
                    print("Tapped on street: \(polyline.title ?? "Unknown")")
                    
                    renderer.strokeColor = .systemRed
                    renderer.invalidatePath()
                    
                    if let street = streets.first(where: { $0.name == polyline.title }) {
                        selectedStreet = street
                    }
                    
                    let rect = polyline.boundingMapRect
                    mapView.setVisibleMapRect(rect,
                                              edgePadding: UIEdgeInsets(top: 60, left: 60, bottom: 60, right: 60),
                                              animated: true)
                    return
                }
            }
            
            selectedStreet = nil
        }
    }
}
