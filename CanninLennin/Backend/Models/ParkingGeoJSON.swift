//
//  ParkingGeoJSON.swift
//  CanninLennin
//
//  Created by Lennin Sabogal on 29/10/25.
//

import Foundation
import CoreLocation


extension CLLocationCoordinate2D: Decodable {
    public enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        var latitude = try values.decode(Double.self, forKey: .latitude)
        var longitude = try values.decode(Double.self, forKey: .longitude)
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
        Restriction(
            panneauId: properties.PANNEAU_ID_RPA, poleId: properties.POTEAU_ID_POT, description: properties.DESCRIPTION_RPA, code: properties.CODE_RPA ?? "UNKOWN", coordinate: CLLocationCoordinate2D(
                latitude: geometry.coordinates[1],
                longitude: geometry.coordinates[2]
            )
        )
    }
}
