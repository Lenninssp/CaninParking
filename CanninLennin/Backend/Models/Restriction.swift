//
//  Restriction.swift
//  CanninLennin
//
//  Created by Lennin Sabogal on 29/10/25.
//

import Foundation
import CoreLocation


struct Restriction: Decodable {
    var id: Int {panneauId}
    let panneauId: Int
    let poleId: Int
    let description: String
    let code: String
    let coordinate: CLLocationCoordinate2D
}
