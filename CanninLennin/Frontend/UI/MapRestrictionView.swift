import SwiftUI
import MapKit

struct MapRestrictionView: View {
    
    @Binding var centerCoordinate: CLLocationCoordinate2D
    
    private let testCoordinate = CLLocationCoordinate2D(
        latitude: 45.46497449834824,
        longitude: -73.63682471756279
    )

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 45.46497449834824,
                longitude: -73.63682471756279
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    )
    
    @State private var restrictions: [RestrictionResponseModel] = []
    @State private var errorMessage: String?
    @State private var isLoading = false

    @State private var selectedRestriction: RestrictionResponseModel?
    @State private var isShowingSheet = false

    private let controller = GetRestrictionsController()

    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $position) {
                ForEach(restrictions, id: \.id) { response in
                    Annotation(
                        response.streetName,
                        coordinate: CLLocationCoordinate2D(
                            latitude: response.latitude,
                            longitude: response.longitude
                        )
                    ) {
                        Button {
                            selectedRestriction = response
                            isShowingSheet = true
                        } label: {
                            VStack(spacing: 2) {
                                Circle()
                                    .fill(permitted(response: response) ? .green : .red)
                                    .frame(width: 12, height: 12)

                                Text(response.streetName)
                                    .font(.caption2)
                                    .padding(4)
                                    .background(.thinMaterial)
                                    .cornerRadius(6)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

            }
            .onMapCameraChange(frequency: .onEnd) { context in
                centerCoordinate = context.region.center
                print("map center:", centerCoordinate.longitude)

                Task {
                    await loadRestrictions()
                }
            }
            .onAppear {
                position = .region(
                    MKCoordinateRegion(
                        center: centerCoordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                    )
                )
                Task {
                    await loadRestrictions()
                }
            }

            if isLoading {
                ProgressView()
                    .padding()
                    .glassEffect(.clear.tint(.gray.opacity(0.2)).interactive(true))
                    .background(.clear)
                    .cornerRadius(12)
                    .padding()
            }

            if let errorMessage {
                Text(errorMessage)
                    .padding(10)
                    .glassEffect(.clear.tint(.gray.opacity(0.2)).interactive(true))
                    .glassEffect(.clear)
                    .foregroundColor(.red)
                    .cornerRadius(8)
                    .padding()
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
        
        let centerLat = centerCoordinate.latitude
        let centerLong = centerCoordinate.longitude
    
        print("this is my latitude \(centerLat), longitude \(centerLong)")

        let request = RestrictionRequestModel(
            longitude: centerLong,
            latitude: centerLat,
            radius: 1500
        )

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
        else {
            return false
        }
        
        let calendar = Calendar.current
        let nowComponents = calendar.dateComponents([.hour, .minute], from: now)
        let nowTime = calendar.date(from: nowComponents)!
        
        return nowTime >= start && nowTime <= end
    }
}

#Preview {
    MapRestrictionView(centerCoordinate: .constant(
        CLLocationCoordinate2D(latitude: 45.4649, longitude: -73.6368)
    ))
}
