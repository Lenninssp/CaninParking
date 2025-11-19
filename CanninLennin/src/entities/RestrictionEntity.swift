import Foundation

struct RestrictionEntity {
    let id: String
    let streetName: String
    let longitude: Double
    let latitude: Double
    let startTime: Date
    let endTime: Date
    let weekdays: [Weekday: Bool]
    let description: String
    let hourlyRate: Int
    
    func isWithinRadius(lat: Double, lng: Double, radius: Double) -> Bool {
        let distance = calculateDistance(to: lat, lng: lng)
        return distance <= radius
    }
    
    func calculateDistance(to lat: Double, lng: Double) -> Double {
        let earthRadius = 6371000.0 
        
        let lat1Rad = latitude * .pi / 180
        let lat2Rad = lat * .pi / 180
        let deltaLat = (lat - latitude) * .pi / 180
        let deltaLng = (lng - longitude) * .pi / 180
        
        let a = sin(deltaLat / 2) * sin(deltaLat / 2) +
                cos(lat1Rad) * cos(lat2Rad) *
                sin(deltaLng / 2) * sin(deltaLng / 2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        return earthRadius * c
    }
}