import Foundation

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
        
        return false
    }
    
}
