//
//  TestGetRestrictions.swift
//  CanninLennin
//
//  Created by Lennin Sabogal on 19/11/25.
//

import SwiftUI

struct TestGetRestrictions: View {
    
    @State private var message: String = "Press button to test"
    let controller = GetRestrictionsController()
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Test Restrictions (100m Radius)") {
                Task {
                    await fetchTestRestrictions()
                }
            }
            .padding()
            .background(Color.blue.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding()
    }
    
    @MainActor
    func fetchTestRestrictions() async {
        
        message = "Loading..."
        
        print("🚀 Testing GetRestrictionsUseCase...")
        
        let controller = GetRestrictionsController()
        
        
        let request = RestrictionRequestModel(
            longitude:-73.581350504631203000,
            latitude: 45.491693947675913000,
            radius: 5000
        )
        
        do {
            let results = try await controller.POST(request: request)
            
            if results.isEmpty {
                print("❌ No restrictions found.")
                message = "No restrictions found in radius."
                return
            }
            
            print("📍 Found \(results.count) restrictions within 100m:")
            for r in results {
                print("""
                -------------------------
                ID: \(r.id)
                Street: \(r.streetName)
                Lat/Lng: \(r.latitude), \(r.longitude)
                Start: \(r.startTime)
                End: \(r.endTime)
                Rate: \(r.hourlyRate)
                Description: \(r.description)
                Weekdays: \(r.weekdays)
                -------------------------
                """)
            }
            
            message = "Loaded \(results.count) restrictions! Check console."
            
        } catch {
            print("❌ ERROR: \(error)")
            message = "Error: \(error.localizedDescription)"
        }
    }
}

#Preview {
    TestGetRestrictions()
}
