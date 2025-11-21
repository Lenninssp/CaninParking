//
//  ApiResponses.swift
//  CanninLennin
//
//  Created by Lennin Sabogal on 19/11/25.
//

import Foundation

struct PlacesResponse: Codable {
    var streetId: String
    var longitude: Double
    var latitude: Double
    var nameStreet: String
    var hourlyRate: Int
}

struct ReglementationPeriodsResponse: Codable {
    var code: String
    var periodId: Int
    var description: String
}

struct PeriodsPersistence: Codable {
    var id: Int
    var startTime: String
    var endTime: String
    var monday: Bool
    var tuesday: Bool
    var wednesday: Bool
    var thursday: Bool
    var friday: Bool
    var saturday: Bool
    var sunday: Bool
}

struct EmplacementReglamentationsResponse: Codable {
    var emplacementId: String
    var codeAutocollant: String
}
