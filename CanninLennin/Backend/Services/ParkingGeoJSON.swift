//
//  ParkingGeoJSON.swift
//  CanninLennin
//
//  Created by Lennin Sabogal on 29/10/25.
//

import Foundation

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
