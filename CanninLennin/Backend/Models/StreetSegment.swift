//
//  StreetSegment.swift
//  CanninLennin
//
//  Created by Lennin Sabogal on 29/10/25.
//

import Foundation

struct Coordinate: Codable {
    let latitude: Double
    let lngitudce: Double
}

struct StreetSegment: Codable {
    let id: String
    let location: [Coordinate]
    let state: StreetState
}

enum StreetState: String, Codable {
    case open
    case restricted
    case closed
}
