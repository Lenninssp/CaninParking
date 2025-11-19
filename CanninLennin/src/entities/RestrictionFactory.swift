//
//  RestrictionFactory.swift
//  CanninLennin
//
//  Created by Lennin Sabogal on 19/11/25.
//

import Foundation

struct RestrictionFactory {
    public func create(
        id: String,
        streetName: String,
        longitude: Double,
        latitude: Double,
        startTime: Date,
        endTime: Date,
        weekdays: [Weekday : Bool],
        description: String,
        hourlyRate: Int
    ) -> RestrictionEntity {
        return RestrictionEntity(id: id, streetName: streetName, longitude: longitude, latitude: latitude, startTime: startTime, endTime: endTime, weekdays: weekdays, description: description, hourlyRate: hourlyRate)
    }
}
