import Foundation

struct RestrictionResponseModel {
    let id: String
    let streetName: String
    let longitude: Double
    let latitude: Double
    let startTime: String
    let endTime: String
    let weekdays: [Weekday: Bool]
    let description: String
    let hourlyRate: Int
    let distanceFromUser: Double 
}
