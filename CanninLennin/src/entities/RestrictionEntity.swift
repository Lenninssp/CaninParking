import Foundation

extension Double {
    var toRadians: Double { self * .pi / 180 }
}

struct RestrictionEntity {
    var id: String
    var streetName: String
    var longitude: Double
    var latitude: Double
    var startTime: Date
    var endTime: Date
    var weekdays: [Weekday: Bool]
    var description: String
    var hourlyRate: Int
    
    public func isWithinRadius(lat: Double, lng: Double, radius: Double) -> Bool {
        let earthRadius = 6371000.0 
        
        let dLat = (lat - latitude).toRadians
        let dLon = (lng - longitude).toRadians
        
        let a = sin(dLat/2) * sin(dLat/2) +
                cos(latitude.toRadians) * cos(lat.toRadians) *
                sin(dLon/2) * sin(dLon/2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        let distance = earthRadius * c
        
        return distance <= radius
    }
}
