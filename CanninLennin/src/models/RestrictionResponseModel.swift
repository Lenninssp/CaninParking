import Foundation

struct RestrictionResponseModel {
    var id: String?
    var streetName: String?
    var longitude: Double?
    var latitude: Double?
    var startTime: Date?
    var endTime: Date?
    var weekdays: [Weekday: Bool]?
    var description: String?
    var hourlyRate: Int?
    var message: String?
    

    init(id: String,
         streetName: String,
         longitude: Double,
         latitude: Double,
         startTime: Date,
         endTime: Date,
         weekdays: [Weekday: Bool],
         description: String,
         hourlyRate: Int
    ) {
        self.id = id
        self.streetName = streetName
        self.longitude = longitude
        self.latitude = latitude
        self.startTime = startTime
        self.endTime = endTime
        self.weekdays = weekdays
        self.description = description
        self.hourlyRate = hourlyRate
        self.message = nil
    }
    

    init(message: String) {
        self.id = nil
        self.streetName = nil
        self.longitude = nil
        self.latitude = nil
        self.startTime = nil
        self.endTime = nil
        self.weekdays = nil
        self.description = nil
        self.hourlyRate = nil
        self.message = message
    }
    
    public func isError() -> Bool {
        return message != nil
    }
}
