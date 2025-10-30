//
//  RestrictionService.swift
//  CanninLennin
//
//  Created by Lennin Sabogal on 29/10/25.
//

import CoreLocation
import Foundation

@MainActor
class RestrictionService {
    static let shared = RestrictionService()
    public init() {}

    private var restrictions: [Restriction] = []

    func load() {

        // if let resourcePath = Bundle.main.resourcePath {
        //     do {
        //         let files = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
        //         print("📦 Files in bundle:")
        //         files.forEach { print(" - \($0)") }
        //     } catch {
        //         print("❌ Error listing bundle contents:", error)
        //     }
        // }

        guard let url = Bundle.main.url(forResource: "Parking.geojson", withExtension: "json")
        else {
            print("Error: there is no parking files")
            return
        }

        let data = try! Data(contentsOf: url)
        print(data.count)
        let geojson = try! JSONDecoder().decode(ParkingGeoJSON.self, from: data)
        self.restrictions = geojson.features.map { $0.toRestriction() }

    }

    func getRestrictions(near userLocation: CLLocationCoordinate2D, maxDistance meters: Double)
        -> [Restriction]
    {
        restrictions.filter { restriction in
            let locationA = CLLocation(
                latitude: restriction.coordinate.latitude,
                longitude: restriction.coordinate.longitude,
            )
            let userLoc = CLLocation(
                latitude: userLocation.latitude,
                longitude: userLocation.longitude
            )

            return locationA.distance(from: userLoc) <= meters
        }
    }

}
