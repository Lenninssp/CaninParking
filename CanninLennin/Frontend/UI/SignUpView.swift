import SwiftUI

struct SignUpView: View {
    @State private var emailInput = ""
    @State private var passwordInput = ""
    @State private var confirmPasswordInput = ""
    @State private var errorMessage: String?

    var onRegistered: () -> Void = {}

    var onCancel: () -> Void = {}

    var body: some View {
        VStack(spacing: 20) {
            Text("Register")
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

            SecureField("Confirm Password", text: $confirmPasswordInput)
                .padding(8)
                .background(.thinMaterial)
                .cornerRadius(15)

            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            Button("Create Account") {
                Task {
                    await register()
                }
            }
            .buttonStyle(.borderedProminent)

            Button("Already have an account? Log in") {
                onCancel()
            }
            .font(.footnote)

            Spacer()
        }
        .padding()
    }

    private func register() async {
        guard passwordInput == confirmPasswordInput else {
            await MainActor.run {
                errorMessage = "Passwords do not match."
            }
            return
        }

        let controller = SignupUserController()
        let request = UserRequestModel(
            email: emailInput,
            password: passwordInput
        )

        do {
            let result = try await controller.POST(request: request)
            print("Signup response:", result)

            await MainActor.run {
                errorMessage = nil
                onRegistered()
            }
        } catch {
            await MainActor.run {
                errorMessage = "Registration error: \(error.localizedDescription)"
            }
            print("Registration error:", error)
        }
    }
}

#Preview {
    SignUpView()
}
