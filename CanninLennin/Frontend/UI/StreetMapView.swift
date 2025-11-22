import SwiftUI
import MapKit

struct StreetMapView: UIViewRepresentable {
    @Binding var streets: [Street]
    @Binding var selectedStreet: Street?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.pointOfInterestFilter = .excludingAll
        mapView.showsUserLocation = false
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        
        // Add all street overlays
        for street in streets {
            let polyline = MKPolyline(coordinates: street.coordinates, count: street.coordinates.count)
            polyline.subtitle = street.id   // Store the unique ID here for later matching
            mapView.addOverlay(polyline)
        }
        
        // Fit map region after load
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let rect = mapView.overlays.reduce(MKMapRect.null) { $0.union($1.boundingMapRect) }
            if !rect.isNull && !rect.isEmpty {
                mapView.setVisibleMapRect(rect,
                                          edgePadding: UIEdgeInsets(top: 60, left: 60, bottom: 60, right: 60),
                                          animated: false)
            } else {
                let montreal = CLLocationCoordinate2D(latitude: 45.55, longitude: -73.6)
                let region = MKCoordinateRegion(center: montreal,
                                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                mapView.setRegion(region, animated: false)
            }
            print("🟦 Added \(mapView.overlays.count) street overlays")
        }
        
        // Tap gesture recognizer
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleMapTap(_:)))
        mapView.addGestureRecognizer(tap)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Only reload overlays if count changes
        if uiView.overlays.count != streets.count {
            uiView.removeOverlays(uiView.overlays)
            for street in streets {
                let polyline = MKPolyline(coordinates: street.coordinates, count: street.coordinates.count)
                polyline.subtitle = street.id   // keep ID here too
                uiView.addOverlay(polyline)
            }
            print("🔄 Reloaded \(streets.count) street overlays in updateUIView")
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(streets: $streets, selectedStreet: $selectedStreet)
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, MKMapViewDelegate {
        @Binding var streets: [Street]
        @Binding var selectedStreet: Street?
        private var renderers: [MKPolyline: MKPolylineRenderer] = [:]
        
        init(streets: Binding<[Street]>, selectedStreet: Binding<Street?>) {
            _streets = streets
            _selectedStreet = selectedStreet
        }
        
        // MARK: - Renderer
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline else { return MKOverlayRenderer() }
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = adjustedLineWidth(for: mapView)
            renderer.lineCap = .round
            renderer.lineJoin = .round
            renderers[polyline] = renderer
            return renderer
        }
        
        // MARK: - Adjust line width based on zoom
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let newWidth = adjustedLineWidth(for: mapView)
            for renderer in renderers.values {
                renderer.lineWidth = newWidth.isFinite ? newWidth : 3.0
                renderer.invalidatePath()
            }
        }
        
        private func adjustedLineWidth(for mapView: MKMapView) -> CGFloat {
            guard mapView.bounds.size.width > 0 else { return 3.0 }
            let zoomScale = mapView.visibleMapRect.size.width / Double(mapView.bounds.size.width)
            let baseWidth: CGFloat = 3.0
            return max(0.5, min(6.0, baseWidth / CGFloat(zoomScale * 0.00005)))
        }
        
        // MARK: - Tap detection using Street ID
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
                    let streetID = polyline.subtitle ?? "unknown"
                    if let street = streets.first(where: { $0.id == streetID }) {
                        selectedStreet = street
                    }
                    renderer.strokeColor = (renderer.strokeColor == .systemRed) ? .systemBlue : .systemRed
                    renderer.invalidatePath()
                    mapView.setVisibleMapRect(polyline.boundingMapRect,
                                              edgePadding: UIEdgeInsets(top: 60, left: 60, bottom: 60, right: 60),
                                              animated: true)
                    return
                }
            }
            
            selectedStreet = nil
        }
    }
}
