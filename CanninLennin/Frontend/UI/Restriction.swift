//
//  Restriction.swift
//  CanninLennin
//
//  Created by Camilo Montero on 2025-10-30.
//

import Foundation
import CoreLocation

struct Restriction: Codable {
    let id: Int
    let description: String
    let code: String
    let longitude: Double
    let latitude: Double
    let arrondissement: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension Restriction {
    static func loadRestrictions() -> [Restriction] {
        guard let url = Bundle.main.url(forResource: "signalisation", withExtension: "json") else {
            print("❌ Restriction file not found")
            return []
        }
        do {
            print("Restriction file found")
            let data = try Data(contentsOf: url)
            let collection = try JSONDecoder().decode(RestrictionFeatureCollection.self, from: data)
            return collection.features.map { $0.toRestriction() }
        } catch {
            print("❌ Error decoding restrictions: \(error)")
            return []
        }
    }
}

// --- GeoJSON wrapper for decoding ---
struct RestrictionFeatureCollection: Codable {
    let features: [RestrictionFeature]
}

struct RestrictionFeature: Codable {
    let properties: RestrictionProperties
    let geometry: RestrictionGeometry
    
    func toRestriction() -> Restriction {
        Restriction(
            id: properties.POTEAU_ID_POT,
            description: properties.DESCRIPTION_RPA,
            code: properties.CODE_RPA,
            longitude: geometry.coordinates[0],
            latitude: geometry.coordinates[1],
            arrondissement: properties.NOM_ARROND
        )
    }
}

struct RestrictionProperties: Codable {
    let POTEAU_ID_POT: Int
    let DESCRIPTION_RPA: String
    let CODE_RPA: String
    let NOM_ARROND: String
}

struct RestrictionGeometry: Codable {
    let type: String
    let coordinates: [Double]
}

