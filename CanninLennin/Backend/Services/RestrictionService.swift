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
    private var streetSegments: [StreetSegment] = []

    func getAll() -> [Restriction] {
        return restrictions
    }

    func load() {
        loadRestrictions()
        loadStreetSegments()
    }

    func loadStreetSegments() {

        guard let url = Bundle.main.url(forResource: "gbdouble", withExtension: "json") else {
            print("gbdouble.json not found")
            return
        }

        do {
            let data = try! Data(contentsOf: url)
            let geojson = try JSONDecoder().decode(StreetSegmentGeoJSON.self, from: data)

            self.streetSegments = geojson.features.map({ $0.toStreetSegment() })

            print("Street segments loaded: ", streetSegments.count)
        } catch {
            print("Error decoding gdouble.json: ", error)
        }
    }

    func loadRestrictions() {

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
        let geojson = try! JSONDecoder().decode(ParkingGeoJSON.self, from: data)
        self.restrictions = geojson.features.map { $0.toRestriction() }

    }

    func getRestrictions(near userLocation: CLLocationCoordinate2D, maxDistance meters: Double)
        -> [Restriction]
    {
        print("🔍 Searching near lat:", userLocation.latitude, "lon:", userLocation.longitude)

        return restrictions.filter { restriction in

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

    func getLongitudeLatitudeRestriction(coordinates userLocation: CLLocationCoordinate2D)
        -> Restriction?
    {
        restrictions.min { a, b in
            let locationA = CLLocation(
                latitude: a.coordinate.latitude, longitude: a.coordinate.longitude)
            let locationB = CLLocation(
                latitude: b.coordinate.latitude, longitude: b.coordinate.longitude)
            let userLoc = CLLocation(
                latitude: userLocation.latitude, longitude: userLocation.longitude)

            return locationA.distance(from: userLoc) < locationB.distance(from: userLoc)
        }
    }

    func getStreetSegments(near userLoaction: CLLocationCoordinate2D, maxDistance meters: Double)
        -> [StreetSegment]
    {
        let userLoc = CLLocation(
            latitude: userLoaction.latitude,
            longitude: userLoaction.longitude,
        )

        return streetSegments.filter { segment in
            segment.coordinates.contains { point in
                let coord = CLLocation(latitude: point.latitude, longitude: point.longitude)
                return coord.distance(from: userLoc) <= meters
            }
        }

    }

}
