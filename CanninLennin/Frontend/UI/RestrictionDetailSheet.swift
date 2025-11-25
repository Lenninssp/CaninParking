//
//  RestrictionDetailSheet.swift
//  CanninLennin
//
//  Created by Camilo Montero on 2025-11-22.
//

import SwiftUI

struct RestrictionDetailSheet: View {
    let restriction: RestrictionResponseModel

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 12) {
                Text(restriction.streetName)
                    .font(.title2)
                    .bold()

                Text(restriction.description)
                    .font(.body)

                HStack {
                    Text("From: \(restriction.startTime)")
                    Text("To: \(restriction.endTime)")
                }
                .font(.subheadline)

                Text("Hourly rate: \(restriction.hourlyRate)$")
                    .font(.subheadline)

                Text("Distance: \(Int(restriction.distanceFromUser)) m")
                    .font(.subheadline)

                Spacer()
            }
            .padding()
            .navigationTitle("Restriction")
            .navigationBarTitleDisplayMode(.inline)
            .glassEffect(.clear)
        }
    }
}

#Preview {
    RestrictionDetailSheet(
        restriction: RestrictionResponseModel(
            id: "123",
            streetName: "Saint Catherine St",
            longitude: -73.5673,
            latitude: 45.5017,
            startTime: "08:00",
            endTime: "18:00",
            weekdays: [
                .monday: true,
                .tuesday: true,
                .wednesday: true,
                .thursday: true,
                .friday: false,
                .saturday: false,
                .sunday: false
            ],
            description: "No parking",
            hourlyRate: 3,
            distanceFromUser: 120
        )
    )
}
