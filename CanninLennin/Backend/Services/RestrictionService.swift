//
//  RestrictionService.swift
//  CanninLennin
//
//  Created by Lennin Sabogal on 29/10/25.
//

import Foundation
import CoreLocation


class RestrictionService {
    static let shared = RestrictionService()
    private init() {}
    
    private var restrictions: [Restriction] = []
    
    func load() {
        guard let url = Bundle.main.url(forResource: "Parking", withExtension: "geojson") else {
            print("Error: there is no parking files")
            return
        }
        
        let data = try! Data(contentsOf: url)
        let geojson = try! JSONDecoder().decode(ParkingGeoJSON.self, from: data)
        
        self.restrictions = geojson.features.map { $0.toRestriction()}
        
        print("Restrictions loaded successfully:", restrictions.count)
           
    }
    
    func getRestrictions(near userLocation: CLLocationCoordinate2D, maxDistance meters: Double) -> [Restriction] {
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
