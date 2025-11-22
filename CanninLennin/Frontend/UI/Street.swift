import Foundation
import MapKit

// MARK: - Top-level GeoJSON object
struct FeatureCollection: Codable {
    let type: String
    let name: String
    let features: [Feature]
}

// MARK: - Individual feature
struct Feature: Codable {
    let type: String
    let geometry: Geometry
    let properties: Properties
}

// MARK: - Geometry data
struct Geometry: Codable {
    let type: String
    let coordinates: [[Double]]
}

// MARK: - Street properties
struct Properties: Codable {
    let COTE_RUE_ID: Int
    let ID_TRC: Int
    let ID_VOIE: Int
    let NOM_VOIE: String
    let NOM_VILLE: String
    let DEBUT_ADRESSE: Int
    let FIN_ADRESSE: Int
    let COTE: String
    let TYPE_F: String
    let SENS_CIR: Int
}

// MARK: - Street model
struct Street: Equatable {
    var id: String
    var name: String              // Original name (e.g. "Walkley")
    var normalizedName: String    // Normalized (for matching)
    var coordinates: [CLLocationCoordinate2D]
    var restrictions: [Restriction] = []
    
    static func == (lhs: Street, rhs: Street) -> Bool {
        lhs.id == rhs.id && lhs.normalizedName == rhs.normalizedName
    }
}

// MARK: - Decoding helper
extension Street {
    init(from feature: Feature) {
        let rawName = feature.properties.NOM_VOIE
        
        self.id = String(feature.properties.COTE_RUE_ID)
        self.name = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.normalizedName = rawName
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .replacingOccurrences(of: "’", with: "'") // normalize apostrophes
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        
        self.coordinates = feature.geometry.coordinates.map {
            CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0])
        }
    }
}

// MARK: - Loader
func loadStreets() -> [Street] {
    guard let url = Bundle.main.url(forResource: "gbdouble", withExtension: "json") else {
        print("❌ gbdouble.json not found")
        return []
    }

    do {
        let data = try Data(contentsOf: url)
        let collection = try JSONDecoder().decode(FeatureCollection.self, from: data)
        let streets = collection.features.map { Street(from: $0) }
        print("✅ Loaded \(streets.count) streets from \(collection.name)")
        
        // Debug: log normalized names
        for s in streets {
            print("📄 Street loaded:", s.name, "| normalized:", s.normalizedName)
        }
        return streets
    } catch {
        print("❌ Error decoding gbdouble.json: \(error)")
        return []
    }
}

// MARK: - Restriction assignment
func assignRestrictions(_ restrictions: [Restriction], to streets: inout [Street]) {
    for restriction in restrictions {
        let point = MKMapPoint(restriction.coordinate)
        var nearestIndex: Int?
        var nearestDistance: Double = .infinity
        
        for (i, street) in streets.enumerated() {
            let polyline = MKPolyline(coordinates: street.coordinates, count: street.coordinates.count)
            let distance = distanceFromPoint(point, toPolyline: polyline)
            
            if distance < nearestDistance {
                nearestDistance = distance
                nearestIndex = i
            }
        }
        
        if let nearestIndex = nearestIndex, nearestDistance < 25 {
            streets[nearestIndex].restrictions.append(restriction)
        }
    }
}

// MARK: - Distance helpers
private func distanceFromPoint(_ point: MKMapPoint, toPolyline polyline: MKPolyline) -> Double {
    let path = polyline.points()
    var minDistance = Double.greatestFiniteMagnitude
    
    for i in 0..<polyline.pointCount - 1 {
        let ptA = path[i]
        let ptB = path[i + 1]
        let dist = distanceFrom(point, toSegmentA: ptA, B: ptB)
        minDistance = min(minDistance, dist)
    }
    return minDistance
}

private func distanceFrom(_ point: MKMapPoint, toSegmentA a: MKMapPoint, B b: MKMapPoint) -> Double {
    let dx = b.x - a.x
    let dy = b.y - a.y
    if dx == 0 && dy == 0 {
        return point.distance(to: a)
    }
    let t = max(0, min(1, ((point.x - a.x) * dx + (point.y - a.y) * dy) / (dx * dx + dy * dy)))
    let projX = a.x + t * dx
    let projY = a.y + t * dy
    return point.distance(to: MKMapPoint(x: projX, y: projY))
}
