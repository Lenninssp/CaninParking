import SwiftUI

struct FloatingNavBar: View {
    @Binding var selectedTab: ContentView.Tab
    @Binding var isSearching: Bool
    @Binding var query: String
    @FocusState.Binding var searchFocused: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack{
                RoundedRectangle(cornerRadius: 20)
                    .fill(.clear)
                    .glassEffect(.clear.tint(.gray.opacity(0.2)).interactive(true))
                    .frame(width: 320, height: 55)
                    .shadow(color: .black.opacity(0.2), radius: 20, y: 8)
            }
            VStack{
                HStack{
                    Spacer()
                    if isSearching {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")

                            TextField("Search...", text: $query)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .focused($searchFocused)

                            Button {
                                withAnimation(.easeOut) {
                                    collapseSearch()
                                    selectedTab = .home
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .glassEffect(.clear.tint(.gray.opacity(0.2)).interactive(true), in: .rect(cornerRadius: 20.0))
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    } else {
                        Button {
                            withAnimation(.easeInOut) {
                                isSearching = true
                                selectedTab = .search
                                searchFocused = true
                            }
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(10)
                        }
                        .glassEffect(.clear.tint(.gray.opacity(0.2)).interactive(true), in: .circle)
                        .buttonStyle(.plain)
                        .transition(.move(edge: .trailing).combined(with: .opacity).combined(with: .opacity))
                    }
                }
                Spacer()
                HStack {
                    NavButton(
                        systemName: "magnifyingglass",
                        isSelected: selectedTab == .search
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            selectedTab = .search
                            isSearching = true
                            searchFocused = true
                        }
                    }

                    Spacer()

                    NavButton(
                        label: "P",
                        isSelected: selectedTab == .home
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            selectedTab = .home
                            collapseSearch()
                        }
                    }

                    Spacer()

                    NavButton(
                        systemName: "gear",
                        isSelected: selectedTab == .settings
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            selectedTab = .settings
                            collapseSearch()
                        }
                    }
                }
                .frame(width: 300, height: 55)
            }
            .padding(.horizontal, 16)

        }
        
                .ignoresSafeArea(.keyboard)


            
    }

    private func collapseSearch() {
        isSearching = false
        searchFocused = false
    }
}

struct NavButton: View {
    var systemName: String? = nil
    var label: String? = nil
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(.clear)
                    .glassEffect(.clear)
                    .opacity(isSelected ? 1 : 0)
                    .frame(
                        width: isSelected ? 74 : 44,
                        height: isSelected ? 64 : 44
                    )
                    .shadow(
                        color: Color.white.opacity(isSelected ? 0.25 : 0),
                        radius: isSelected ? 20 : 0,
                        y: isSelected ? 8 : 0
                    )
                    .zIndex(0)

                Group {
                    if let systemName = systemName {
                        Image(systemName: systemName)
                            .font(.system(size: isSelected ? 23 : 20, weight: isSelected ? .bold : .semibold))

                    } else if let label = label {
                        Text(label)
                        .font(.system(size: isSelected ? 23 : 20, weight: isSelected ? .bold : .semibold))                    }
                }
                .frame(width: 44, height: 44)
                .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                .zIndex(1)
            }
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
}

struct FloatingNavBar_Previews: PreviewProvider {
    @State static var selectedTab: ContentView.Tab = .search
    @State static var isSearching: Bool = false
    @State static var query: String = "Garage"
    @FocusState static var searchFocused: Bool

    static var previews: some View {
        ZStack {
            FloatingNavBar(
                selectedTab: $selectedTab,
                isSearching: $isSearching,
                query: $query,
                searchFocused: $searchFocused
            )
        }
        .preferredColorScheme(.dark)
    }
}
