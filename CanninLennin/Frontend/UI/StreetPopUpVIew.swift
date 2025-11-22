import SwiftUI
import MapKit

struct StreetPopUpView: View {
    @State private var selectedStreet: Street? = nil
    @State private var streets: [Street] = []
    @State private var hasLoaded = false


    
    
    var body: some View {
        ZStack {
            StreetMapView(streets: $streets, selectedStreet: $selectedStreet)
                .ignoresSafeArea()
            
            // Bottom popup
            if let street = selectedStreet {
                VStack {
                    Spacer()
                    VStack(spacing: 6) {
                        Text(street.name)
                            .font(.headline)
                            .padding(.top, 4)
                        
                        if !street.restrictions.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(street.restrictions, id: \.id) { r in
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(r.description)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                            .padding(.top, 6)
                        } else {
                            Text("No restrictions")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .glassEffect(.clear)
                    .background(.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 10)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 90)

                }
            }
        }
        .animation(.spring(), value: selectedStreet)
        .task {
            if !hasLoaded {
                hasLoaded = true
                loadData()
            }
        }
    }
    
    // MARK: - Load Data
    func loadData() {
        var streetList = loadStreets()
        let restrictionList = Restriction.loadRestrictions()
        
        assignRestrictions(restrictionList, to: &streetList)
        streets = streetList
        
        print("✅ Loaded \(streetList.count) streets")
        for street in streetList {
            print("\(street.name): \(street.restrictions.count) restrictions")
        }
    }
}

#Preview {
    StreetPopUpView()
}
