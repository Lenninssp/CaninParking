//
//  ParkingGeoJSON.swift
//  CanninLennin
//
//  Created by Lennin Sabogal on 29/10/25.
//

import CoreLocation
import Foundation

extension CLLocationCoordinate2D: @retroactive Decodable {
    public enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try values.decode(Double.self, forKey: .latitude)
        let longitude = try values.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
}

struct ParkingGeoJSON: Decodable {
    let features: [ParkingFeature]
}

struct ParkingFeature: Decodable {
    let properties: ParkingProperties
    let geometry: ParkingGeometry
}

struct ParkingProperties: Decodable {
    let POTEAU_ID_POT: Int
    let PANNEAU_ID_RPA: Int
    let DESCRIPTION_RPA: String
    let CODE_RPA: String?
}

struct ParkingGeometry: Decodable {
    let coordinates: [Double]
}

extension ParkingFeature {
    func toRestriction() -> Restriction {
        let lon = geometry.coordinates.first
        let lat = geometry.coordinates.dropFirst().first

        let coord = CLLocationCoordinate2D(
            latitude: lat ?? 0,
            longitude: lon ?? 0
        )

        return Restriction(
            panneauId: properties.PANNEAU_ID_RPA, poleId: properties.POTEAU_ID_POT,
            description: properties.DESCRIPTION_RPA, code: properties.CODE_RPA ?? "UNKOWN",
            coordinate: coord
        )
    }
}
