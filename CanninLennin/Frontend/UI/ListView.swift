import SwiftUI
import CoreLocation

struct ListView: View {
    let centerCoordinate: CLLocationCoordinate2D
    
    @State private var restrictions: [RestrictionResponseModel] = []
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var selectedRestriction: RestrictionResponseModel?
    @State private var isShowingSheet = false
    
    private let controller = GetRestrictionsController()
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Restrictions nearby")
                        .font(.headline)
                    Spacer()
                    Text("\(restrictions.count)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 4)
                
                Divider()
                
                if restrictions.isEmpty && !isLoading {
                    Text("No restrictions found in radius.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(restrictions, id: \.id) { response in
                                Button {
                                    selectedRestriction = response
                                    isShowingSheet = true
                                } label: {
                                    HStack(alignment: .top, spacing: 12) {
                                        Circle()
                                            .fill(permitted(response: response) ? .green : .red)
                                            .frame(width: 10, height: 10)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(response.streetName)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            
                                            Text("\(response.startTime) - \(response.endTime)")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(8)
                                    .background(.thinMaterial)
                                    .cornerRadius(12)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .frame(height: 620)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.clear)
                    .glassEffect(
                        .clear.tint(.gray.opacity(0.2)).interactive(),
                        in: .rect(cornerRadius: 20)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 20, y: 8)
            )
            .padding()
            .task(id: centerCoordinate.latitude + centerCoordinate.longitude) {
                await loadRestrictions()
            }
            
            if isLoading {
                ProgressView()
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(12)
            }
            
            if let errorMessage {
                VStack {
                    Text(errorMessage)
                        .padding(10)
                        .background(.thinMaterial)
                        .foregroundColor(.red)
                        .cornerRadius(8)
                        .padding()
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $isShowingSheet) {
            if let r = selectedRestriction {
                RestrictionDetailSheet(restriction: r)
            }
        }
    }

    @MainActor
    private func loadRestrictions() async {
        isLoading = true
        errorMessage = nil
        
        let request = RestrictionRequestModel(
            longitude: centerCoordinate.longitude,
            latitude: centerCoordinate.latitude,
            radius: 1500
        )
        
        print("ListView center:", centerCoordinate.latitude, centerCoordinate.longitude)
        
        do {
            let results = try await controller.POST(request: request)
            
            if results.isEmpty {
                errorMessage = "No restrictions found in radius."
                restrictions = []
            } else {
                restrictions = results
            }
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
        
    private let hourFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
    
    private func permitted(response: RestrictionResponseModel) -> Bool {
        let now = Date()
        
        guard
            let start = hourFormatter.date(from: response.startTime),
            let end = hourFormatter.date(from: response.endTime)
        else { return false }
        
        let calendar = Calendar.current
        let nowComponents = calendar.dateComponents([.hour, .minute], from: now)
        let nowTime = calendar.date(from: nowComponents)!
        
        return nowTime >= start && nowTime <= end
    }
}

#Preview {
    ListView(
        centerCoordinate: CLLocationCoordinate2D(
            latitude: 45.4649,
            longitude: -73.6368
        )
    )
}
