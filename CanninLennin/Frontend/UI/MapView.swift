import SwiftUI
import MapKit
final class ColoredPolyline: MKPolyline {
    var isPermitted: Bool = true
}

struct MapView: View {
    // Idea taken out from https://developer.apple.com/documentation/mapkit/mkcoordinateregion
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45.5129527086375, longitude: -73.5705591906721),
        span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
    )

    private let streetCenterline: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 45.5129527086375, longitude: -73.5705591906721),
        CLLocationCoordinate2D(latitude: 45.5124413947124, longitude: -73.5708091694254)
    ]

    var body: some View {
        MapViewRepresentable(region: $region, streetCenterline: streetCenterline)
            .ignoresSafeArea()
    }
}

struct MapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    let streetCenterline: [CLLocationCoordinate2D]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = region
        addParallelPolylines(to: mapView)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.region = region
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    private func addParallelPolylines(to mapView: MKMapView) {
        guard streetCenterline.count >= 2 else { return }

        let leftOffset = offsetPolyline(from: streetCenterline, meters: 3, toLeft: true)
        let rightOffset = offsetPolyline(from: streetCenterline, meters: 3, toLeft: false)

        let leftLine = ColoredPolyline(coordinates: leftOffset, count: leftOffset.count)
        leftLine.isPermitted = true

        let rightLine = ColoredPolyline(coordinates: rightOffset, count: rightOffset.count)
        rightLine.isPermitted = false

        mapView.addOverlays([leftLine, rightLine])
    }

    private func offsetPolyline(from coords: [CLLocationCoordinate2D], meters: Double, toLeft: Bool) -> [CLLocationCoordinate2D] {
        guard coords.count >= 2 else { return coords }

        var offsetCoords: [CLLocationCoordinate2D] = []

        for i in 0..<(coords.count - 1) {
            let p1 = coords[i]
            let p2 = coords[i + 1]

            let m1 = MKMapPoint(p1)
            let m2 = MKMapPoint(p2)

            let dx = m2.x - m1.x
            let dy = m2.y - m1.y
            let length = sqrt(dx * dx + dy * dy)

            let ux = -dy / length
            let uy = dx / length

            let metersPerPoint = MKMetersPerMapPointAtLatitude(p1.latitude)
            let offset = meters / metersPerPoint * (toLeft ? 1 : -1)

            let offsetP1 = MKMapPoint(x: m1.x + ux * offset, y: m1.y + uy * offset)
            let offsetP2 = MKMapPoint(x: m2.x + ux * offset, y: m2.y + uy * offset)

            if i == 0 { offsetCoords.append(offsetP1.coordinate) }
            offsetCoords.append(offsetP2.coordinate)
        }

        return offsetCoords
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? ColoredPolyline else { return MKOverlayRenderer() }

            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = polyline.isPermitted ? .systemGreen : .systemRed
            renderer.lineWidth = 5
            renderer.lineCap = .round
            return renderer
        }
    }
}

#Preview {
    MapView()
}
