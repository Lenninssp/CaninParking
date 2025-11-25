import Foundation

enum Weekday: String, Codable, Hashable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}

struct RestrictionPersistence: Codable {
    var id: String
    var streetName: String
    var longitude: Double
    var latitude: Double
    var description: String
    var hourlyRate: Int
    var startTime: String
    var endTime: String
    var weekdays: [Weekday: Bool]
}
