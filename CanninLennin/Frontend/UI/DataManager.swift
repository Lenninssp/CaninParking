//
//  DataManager.swift
//  CanninLennin
//
//  Created by Camilo Montero on 2025-10-30.
//

import Foundation

enum DataManager {
    static func loadAllStreets() -> [Street] {
        var streets = loadStreets()
        let restrictions = Restriction.loadRestrictions()
        assignRestrictions(restrictions, to: &streets)
        return streets
    }
}
