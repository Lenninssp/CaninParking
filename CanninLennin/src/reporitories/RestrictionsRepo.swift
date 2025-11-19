import Foundation


struct RestrictionsRepo {
    private let placesLink = "https://www.agencemobilitedurable.ca/images/data/Places.csv"
    private let reglementationLink = "https://www.agencemobilitedurable.ca/images/data/Reglementations.csv"
    private let periodsLink = "https://www.agencemobilitedurable.ca/images/data/Periodes.csv"
    private let emplacementReglementations = "https://www.agencemobilitedurable.ca/images/data/EmplacementReglementation.csv"
    
    func getParkingRestrictions() async throws -> [RestrictionPersistence] {
        
        async let placesCSV = fetchCSV(from: placesLink)
        async let reglCSV = fetchCSV(from: reglementationLink)
        async let periodsCSV = fetchCSV(from: periodsLink)
        async let emplacementCSV = fetchCSV(from: emplacementReglementations)
        
        let (places, regls, periods, empls) = try await (
            parsePlacesCSV(placesCSV),
            parseReglementationsCSV(reglCSV),
            parsePeriodsCSV(periodsCSV),
            parseEmplacementsCSV(emplacementCSV)
        )
        
        var restrictions: [RestrictionPersistence] = []
        
        
        for place in places {
            let placeEmpl = empls.filter { $0.emplacementId == place.streetId }
            
            for e in placeEmpl {
                guard let regl = regls.first(where: { $0.code == e.codeAutocollant }) else {
                    continue
                }
                
                guard let period = periods.first(where: { $0.id == regl.periodId }) else {
                    continue
                }
                
                let weekdaysDict: [Weekday: Bool] = [
                    .monday: period.monday,
                    .tuesday: period.tuesday,
                    .wednesday: period.wednesday,
                    .thursday: period.thursday,
                    .friday: period.friday,
                    .saturday: period.saturday,
                    .sunday: period.sunday
                ]
                
                restrictions.append(
                    RestrictionPersistence(
                        id: place.streetId,
                        streetName: place.nameStreet,
                        longitude: place.longitude,
                        latitude: place.latitude,
                        description: regl.description,
                        hourlyRate: place.hourlyRate,
                        startTime: period.startTime,
                        endTime: period.endTime,
                        weekdays: weekdaysDict
                    )
                )
            }
        }
        
        
        
        return restrictions
    }
    
    private func parseEmplacementsCSV(_ csv: String) -> [EmplacementReglamentationsResponse] {
        var result: [EmplacementReglamentationsResponse] = []
        let lines = csv.split(separator: "\n")
        for line in lines.dropFirst() {
            let columns = line.split(separator: ",")
            if columns.count >= 2 {
                result.append(
                    EmplacementReglamentationsResponse(
                        emplacementId: String(columns[0]),
                        codeAutocollant: String(columns[1])
                    )
                )
            }
        }
        
        return result
    }
    
    private func parsePeriodsCSV(_ csv: String) -> [PeriodsPersistence] {
        var result: [PeriodsPersistence] = []
        let lines = csv.split(separator: "\n")
        for line in lines.dropFirst() {
            let col = line.split(separator: ",")
            if col.count >= 10 {
                result.append(
                    PeriodsPersistence(
                        id: Int(col[0]) ?? 0,
                        startTime: String(col[1]),
                        endTime: String(col[2]),
                        monday: col[3] == "1",
                        tuesday: col[4] == "1",
                        wednesday: col[5] == "1",
                        thursday: col[6] == "1",
                        friday: col[7] == "1",
                        saturday: col[8] == "1",
                        sunday: col[9] == "1"
                    )
                )
            }
        }
        
        return result
    }
    
    private func parseReglementationsCSV(_ csv: String) -> [ReglementationPeriodsResponse] {
        var result: [ReglementationPeriodsResponse] = []
        let lines = csv.split(separator: "\n")
        for line in lines.dropFirst(){
            let columns = line.split(separator: ",")
            if columns.count >= 3 {
                result.append(
                    ReglementationPeriodsResponse(code: String(columns[0]), periodId: Int(columns[1]) ?? 0, description: String(columns[2]))
                )
            }
        }
        return result
    }
    
    private func parsePlacesCSV(_ csv: String) -> [PlacesResponse] {
        var result: [PlacesResponse] = []
        let lines = csv.split(separator: "\n")
        for line in lines.dropFirst() {
            let columns = line.split(separator: ",")
            if columns.count >= 5 {
                result.append(
                    PlacesResponse(
                        streetId: String(columns[0]),
                        longitude: Double(columns[1]) ?? 0,
                        latitude: Double(columns[2]) ?? 0,
                        nameStreet: String(columns[3]),
                        hourlyRate: Int(columns[4]) ?? 0
                    )
                )
            }
        }
        return result
    }
    
    private func fetchCSV(from urlString: String) async throws -> String {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return String(decoding: data, as: UTF8.self)
    }
    
}
