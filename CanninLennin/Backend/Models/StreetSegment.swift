//
//  StreetSegment.swift
//  CanninLennin
//
//  Created by Lennin Sabogal on 29/10/25.
//
import CoreLocation
import Foundation


struct StreetSegment {
    let id: Int
    let coordinates: [CLLocationCoordinate2D]
    let streetName: String
    let addressStart: Int
    let addressEnd: Int 
}

