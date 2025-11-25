import SwiftUI

struct LogInView: View {
    @State private var emailInput = ""
    @State private var passwordInput = ""
    @State private var errorMessage: String?

    var onLoggedIn: () -> Void = {}

    var onSignUpTapped: () -> Void = {}

    var body: some View {
        VStack(spacing: 20) {
            Text("Login")
                .font(.largeTitle)

            TextField("Email", text: $emailInput)
                .padding(8)
                .background(.thinMaterial)
                .cornerRadius(15)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)

            SecureField("Password", text: $passwordInput)
                .padding(8)
                .background(.thinMaterial)
                .cornerRadius(15)

            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            Button("Log In") {
                Task {
                    await logIn()
                }
            }
            .buttonStyle(.borderedProminent)

            Button("Don't have an account? Sign up") {
                onSignUpTapped()
            }
            .font(.footnote)

            Spacer()
        }
        .padding()
    }

    private func logIn() async {
        let controller = LoginUserController()
        let request = UserRequestModel(
            email: emailInput,
            password: passwordInput
        )

        do {
            let result = try await controller.POST(request: request)
            print("Login response:", result)

            await MainActor.run {
                errorMessage = nil
                onLoggedIn()
            }
        } catch {
            await MainActor.run {
                errorMessage = "Login error: \(error.localizedDescription)"
            }
            print("Login error:", error)
        }
    }
}

#Preview {
    LogInView()
}
