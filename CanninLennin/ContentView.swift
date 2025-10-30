//
//  ContentView.swift
//  ParkingApp
//
//  Created by Juan Camilo Montero Campo on 2025-10-13.
//

import SwiftUI
import MapKit

struct ContentView: View {
    enum Tab {
        case home, settings, search
    }
    
    @State private var selectedTab: Tab = .home
    @State private var isSearching: Bool = false
    @State private var query: String = ""
    
    @FocusState private var searchFocused: Bool
    var body: some View {

        ZStack(alignment: .center) {
            StreetPopUpVIew()
                .ignoresSafeArea()
                .blur(radius: selectedTab == .search || selectedTab == .settings  ? 5 : 0)
            Group{
                switch selectedTab{
                case .home:
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white.opacity(0))
                case .settings:
                    TestView()

                case .search:
                    Text(".")
                    /*ZStack {
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
                            }
                            else{
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
                     */



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
        .ignoresSafeArea(.keyboard, edges: .bottom) // ✅ important: attach to the outer ZStack


    }
}

#Preview {
    ContentView()
}
