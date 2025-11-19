import Foundation

enum Weekday {
  case monday 
  case tuesday
  case wednesday
  case thursday
  case friday
  case saturday
  case sunday
}

struct RestrictionPersistence {
  var id: String
  var streetName: String
  var longitude: Double
  var latitude: Double
  var description: String
  var hourlyRate: Int
  var startTime: String
  var endTime: String
  var week: [Weekday: Bool]
}
