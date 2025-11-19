//
//  RestrictionFactory.swift
//  CanninLennin
//
//  Created by Lennin Sabogal on 19/11/25.
//

import Foundation

struct RestrictionFactory {
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    func createEntity(from persistence: RestrictionPersistence) -> RestrictionEntity? {
        guard let startTime = timeFormatter.date(from: persistence.startTime),
              let endTime = timeFormatter.date(from: persistence.endTime) else {
            print("Failed to parse start and end times: \(persistence.startTime) - \(persistence.endTime)")
            return nil
        }
        
        return RestrictionEntity(
            id: persistence.id,
            streetName: persistence.streetName,
            longitude: persistence.longitude,
            latitude: persistence.latitude,
            startTime: startTime,
            endTime: endTime,
            weekdays: persistence.weekdays,
            description: persistence.description,
            hourlyRate: persistence.hourlyRate
        )
    }
    
    func createResponse(from entity: RestrictionEntity, distanceFromUser: Double) -> RestrictionResponseModel {
        return RestrictionResponseModel(
            id: entity.id,
            streetName: entity.streetName,
            longitude: entity.longitude,
            latitude: entity.latitude,
            startTime: formatTime(entity.startTime),
            endTime: formatTime(entity.endTime),
            weekdays: entity.weekdays,
            description: entity.description,
            hourlyRate: entity.hourlyRate,
            distanceFromUser: distanceFromUser
        )
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}