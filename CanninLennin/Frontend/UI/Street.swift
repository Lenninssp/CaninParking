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

struct Street {
    var id: String
    var name: String
    var coordinates: [CLLocationCoordinate2D]
}

extension Street {
    init(from feature: Feature) {
        self.id = String(feature.properties.COTE_RUE_ID)
        self.name = feature.properties.NOM_VOIE
        self.coordinates = feature.geometry.coordinates.map {
            CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0])
        }
    }
}

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
        return streets
    } catch {
        print("❌ Error decoding gbdouble.json: \(error)")
        return []
    }
}
