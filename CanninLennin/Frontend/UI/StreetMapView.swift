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
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.pointOfInterestFilter = .excludingAll
        mapView.showsUserLocation = false
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        
        // Add overlays for each street
        for street in streets {
            let polyline = MKPolyline(coordinates: street.coordinates, count: street.coordinates.count)
            polyline.title = street.name
            mapView.addOverlay(polyline)
        }
        
        // Fit map region
        let rect = mapView.overlays.reduce(MKMapRect.null) { $0.union($1.boundingMapRect) }
        mapView.setVisibleMapRect(rect,
                                  edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50),
                                  animated: false)
        
        // Add gesture recognizer for taps
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleMapTap(_:)))
        mapView.addGestureRecognizer(tap)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}

extension StreetMapView {
    class Coordinator: NSObject, MKMapViewDelegate {
        
        // Cache of renderers so we can update their width dynamically
        private var renderers: [MKPolyline: MKPolylineRenderer] = [:]
        
        // MARK: - Renderer for streets
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline else {
                return MKOverlayRenderer()
            }
            
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = adjustedLineWidth(for: mapView)
            
            renderers[polyline] = renderer
            return renderer
        }
        
        // MARK: - Adjust thickness when zoom changes
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let newWidth = adjustedLineWidth(for: mapView)
            for renderer in renderers.values {
                renderer.lineWidth = newWidth
                renderer.invalidatePath()
            }
        }
        
        // Compute thickness based on zoom scale
        private func adjustedLineWidth(for mapView: MKMapView) -> CGFloat {
            // The larger the visible map rect, the more zoomed out you are
            // We'll map that inversely to line width
            let zoomScale = mapView.visibleMapRect.size.width / Double(mapView.bounds.size.width)
            let baseWidth: CGFloat = 3.0
            let adjusted = max(0.5, min(6.0, baseWidth / CGFloat(zoomScale * 0.00005)))
            return adjusted
        }
        
        // MARK: - Tap detection
        @objc func handleMapTap(_ gestureRecognizer: UITapGestureRecognizer) {
            guard let mapView = gestureRecognizer.view as? MKMapView else { return }
            let tapPoint = gestureRecognizer.location(in: mapView)
            let tapCoordinate = mapView.convert(tapPoint, toCoordinateFrom: mapView)
            let mapPoint = MKMapPoint(tapCoordinate)
            
            for overlay in mapView.overlays {
                guard let polyline = overlay as? MKPolyline,
                      let renderer = mapView.renderer(for: polyline) as? MKPolylineRenderer else { continue }
                
                let cgPoint = renderer.point(for: mapPoint)
                let hitBox = renderer.path?.copy(strokingWithWidth: renderer.lineWidth * 4,
                                                 lineCap: .round, lineJoin: .round, miterLimit: 0)
                
                if let hitBox = hitBox, hitBox.contains(cgPoint) {
                    print("✅ Tapped on street: \(polyline.title ?? "Unknown")")
                    
                    renderer.strokeColor = .systemRed
                    renderer.invalidatePath()
                    
                    // Zoom into tapped line
                    let rect = polyline.boundingMapRect
                    mapView.setVisibleMapRect(rect,
                                              edgePadding: UIEdgeInsets(top: 60, left: 60, bottom: 60, right: 60),
                                              animated: true)
                    return
                }
            }
        }
    }
}
