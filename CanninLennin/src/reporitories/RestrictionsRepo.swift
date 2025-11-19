import Foundation

struct RestrictionsRepo {
    private let placesLink = "https://www.agencemobilitedurable.ca/images/data/Places.csv"
    private let reglementationLink =
        "https://www.agencemobilitedurable.ca/images/data/Reglementations.csv"
    private let periodsLink = "https://www.agencemobilitedurable.ca/images/data/Periodes.csv"
    private let emplacementReglementations =
        "https://www.agencemobilitedurable.ca/images/data/EmplacementReglementation.csv"

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

        print(
            "places: \(places.count), regles: \(regls.count), periods: \(periods.count), empls: \(empls.count)"
        )

        let reglDict = Dictionary(uniqueKeysWithValues: regls.map { ($0.code, $0) })
        let periodDict = Dictionary(uniqueKeysWithValues: periods.map { ($0.id, $0) })
        let emplsByPlace = Dictionary(grouping: empls, by: { $0.emplacementId })

        var restrictions: [RestrictionPersistence] = []

        for place in places {
            guard let placeEmpls = emplsByPlace[place.streetId] else { continue }
            for empl in placeEmpls {
                guard let regl = reglDict[empl.codeAutocollant],
                    let period = periodDict[regl.periodId]
                else {
                    continue
                }

                let weekdaysDict: [Weekday: Bool] = [
                    .monday: period.monday,
                    .tuesday: period.tuesday,
                    .wednesday: period.wednesday,
                    .thursday: period.thursday,
                    .friday: period.friday,
                    .saturday: period.saturday,
                    .sunday: period.sunday,
                ]
                
                // print("ATTENTION")
                // print(
                //     RestrictionPersistence(
                //         id: place.streetId,
                //         streetName: place.nameStreet,
                //         longitude: place.longitude,
                //         latitude: place.latitude,
                //         description: regl.description,
                //         hourlyRate: place.hourlyRate,
                //         startTime: period.startTime,
                //         endTime: period.endTime,
                //         weekdays: weekdaysDict
                //     ))

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
        let lines = csv.components(separatedBy: .newlines).filter { !$0.isEmpty }

        for line in lines.dropFirst() {
            let columns = line.split(separator: ",").map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            if columns.count >= 2 {
                result.append(
                    EmplacementReglamentationsResponse(
                        emplacementId: columns[0],
                        codeAutocollant: columns[1]
                    )
                )
            }
        }
        return result
    }

    private func parsePeriodsCSV(_ csv: String) -> [PeriodsPersistence] {
        var result: [PeriodsPersistence] = []
        let lines = csv.components(separatedBy: .newlines).filter { !$0.isEmpty }

        for line in lines.dropFirst() {
            let columns = line.split(separator: ",").map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            if columns.count >= 10 {
                result.append(
                    PeriodsPersistence(
                        id: Int(columns[0]) ?? 0,
                        startTime: columns[1],
                        endTime: columns[2],
                        monday: columns[3] == "1",
                        tuesday: columns[4] == "1",
                        wednesday: columns[5] == "1",
                        thursday: columns[6] == "1",
                        friday: columns[7] == "1",
                        saturday: columns[8] == "1",
                        sunday: columns[9] == "1"
                    )
                )
            }
        }
        return result
    }

    private func parseReglementationsCSV(_ csv: String) -> [ReglementationPeriodsResponse] {
        var result: [ReglementationPeriodsResponse] = []
        let lines = csv.components(separatedBy: .newlines).filter { !$0.isEmpty }

        for line in lines.dropFirst() {
            let columns = line.split(separator: ",").map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            if columns.count >= 3 {
                result.append(
                    ReglementationPeriodsResponse(
                        code: columns[0],
                        periodId: Int(columns[2]) ?? 0,
                        description: columns[3]
                    )
                )
            }
        }
        return result
    }

    private func parsePlacesCSV(_ csv: String) -> [PlacesResponse] {
        var result: [PlacesResponse] = []
        let lines = csv.components(separatedBy: .newlines).filter { !$0.isEmpty }

        for line in lines.dropFirst() {
            let columns = line.split(separator: ",").map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            if columns.count >= 15 {
                result.append(
                    PlacesResponse(
                        streetId: columns[0],
                        longitude: Double(columns[1]) ?? 0,
                        latitude: Double(columns[2]) ?? 0,
                        nameStreet: columns[9],
                        hourlyRate: Int(columns[12]) ?? 0
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
        if #available(macOS 12.0, *) {
            let (data, _) = try await URLSession.shared.data(from: url)
            return String(decoding: data, as: UTF8.self)
        } else {
            return ""
        }
    }
}
