import SwiftUI

struct AuthenticationSwitcher: View {
    @State private var isLoggedIn = false
    @State private var showingSignUp = false
    @State private var didCheckAuth = false

    var body: some View {
        NavigationStack {
            Group {
                if !didCheckAuth {
                    ProgressView("Checking authentication...")
                } else if isLoggedIn {
                    ContentView(onLogout: handleLogout)
                } else if showingSignUp {
                    SignUpView(
                        onRegistered: handleSignUpSuccess,
                        onCancel: { showingSignUp = false }
                    )
                } else {
                    LogInView(
                        onLoggedIn: handleLoginSuccess,
                        onSignUpTapped: { showingSignUp = true }
                    )
                }
            }
        }
        .task {
            await checkAuth()
        }
    }


    @MainActor
    private func handleLoginSuccess() {
        isLoggedIn = true
        showingSignUp = false
    }

    @MainActor
    private func handleSignUpSuccess() {
        isLoggedIn = true
        showingSignUp = false
    }

    @MainActor
    private func handleLogout() {
        isLoggedIn = false
        showingSignUp = false
    }


    @MainActor
    private func checkAuth() async {
        let controller = GetUserController()

        do {
            let result = try await controller.GET()
            isLoggedIn = result.isSuccess()
        } catch {
            isLoggedIn = false
        }

        didCheckAuth = true
    }
}
