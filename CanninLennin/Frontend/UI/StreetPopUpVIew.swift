//
//  StreetPopUpVIew.swift
//  CanninLennin
//
//  Created by Camilo Montero on 2025-10-29.
//

import SwiftUI
import MapKit

struct StreetPopUpVIew: View {
    @State private var selectedStreet: Street? = nil
    private let streets = loadStreets()
    var body: some View {
        ZStack {
                    // 👇 FIX: pass $selectedStreet
                    StreetMapView(streets: streets, selectedStreet: $selectedStreet)
                        .ignoresSafeArea()
                    
                    // Popup when a street is tapped
                    if let street = selectedStreet {
                        VStack {
                            Spacer()
                            VStack(spacing: 6) {
                                Text(street.name)
                                    .font(.headline)
                                Text(street.coordinates.count > 1
                                     ? "\(street.coordinates.count) points"
                                     : "1 point")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.clear)
                            .glassEffect(.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(radius: 10)
                            .padding()
                            .padding(.bottom, 90)

                        }
                        .transition(.move(edge: .bottom))
                    }
                }
                .animation(.spring(), value: selectedStreet)
    }
}

#Preview {
    StreetPopUpVIew()
}
