import SwiftUI
import MapKit

struct MapView3: View {
    @State private var selectedStreet: Street? = nil
    @State private var streets: [Street] = []        // <-- now mutable
    @State private var restrictions: [Restriction] = []
    
    var body: some View {
        ZStack {
            StreetMapView(streets: $streets, selectedStreet: $selectedStreet)
                .ignoresSafeArea()
            
            // Popup when a street is tapped
            if let street = selectedStreet {
                VStack {
                    Spacer()
                    VStack(spacing: 6) {
                        Text(street.name)
                            .font(.headline)
                        if !street.restrictions.isEmpty {
                            Text("\(street.restrictions.count) restrictions")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 10)
                    .padding()
                }
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.spring(), value: selectedStreet)
        .onAppear {
            loadData()
        }
    }
    
    // 👇 All your JSON loading and linking logic here
    func loadData() {
        var streetList = loadStreets()
        let restrictionList = Restriction.loadRestrictions()
        
        assignRestrictions(restrictionList, to: &streetList)
        
        streets = streetList
        restrictions = restrictionList
        
        // Debug print
        for street in streetList {
            print("\(street.name): \(street.restrictions.count) restrictions")
        }
    }
 
}


#Preview {
    MapView3()
}
