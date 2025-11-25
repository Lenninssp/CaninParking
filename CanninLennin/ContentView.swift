import SwiftUI
import MapKit

struct ContentView: View {
    enum Tab {
        case home, listview, search, profile
    }
    
    var onLogout: () -> Void = {}

    @State private var selectedTab: Tab = .home
    @State private var isSearching: Bool = false
    @State private var query: String = ""
    @FocusState private var searchFocused: Bool

    @State private var centerCoordinate = CLLocationCoordinate2D(
        latitude: 45.46497449834824,
        longitude: -73.63682471756279
    )
    
    var body: some View {
        ZStack(alignment: .center) {
            MapRestrictionView(centerCoordinate: $centerCoordinate)
                .blur(radius: selectedTab == .search || selectedTab == .listview || selectedTab == .profile  ? 5 : 0)
            
            Group {
                switch selectedTab {
                case .home:
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white.opacity(0))
                    
                case .listview:
                    ListView(centerCoordinate: centerCoordinate)
                    
                case .search:
                    Text(".")
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.black.opacity(0.08))
                            .frame(width: 350, height: 620)
                            .glassEffect(.clear.tint(.gray.opacity(0.2)).interactive(true), in: .rect(cornerRadius: 20.0))
                            .shadow(color: .black.opacity(0.2), radius: 20, y: 8)
                        
                        VStack(alignment: .leading, spacing: 12){
                            Text("Search")
                                .font(.largeTitle.bold())
                                .foregroundColor(.white)
                            
                            if query.isEmpty {
                                Text("Type something to search")
                                    .foregroundColor(.white.opacity(0.9))
                            } else {
                                Text("Result for: \(query)")
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            Spacer()
                        }
                        .padding(20)
                        .frame(width: 350, height: 620)
                        .ignoresSafeArea(.keyboard)
                    }
                    .ignoresSafeArea(.keyboard)
                    
                case .profile:
                    LogOutView(onLoggedOut: onLogout)
                }
            }
            .ignoresSafeArea(.keyboard)
            .onTapGesture {
                searchFocused = false
            }
            
            FloatingNavBar(
                selectedTab: $selectedTab,
                isSearching: $isSearching,
                query: $query,
                searchFocused: $searchFocused
            )
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
