//
//  LogOutView.swift
//  CanninLennin
//
//  Created by Camilo Montero on 2025-11-24.
//

import SwiftUI

struct LogOutView: View {
    var onLoggedOut: () -> Void = {}

    var body: some View {
        Button("Log Out") {
            Task {
                let controller = LogoutUserController()
                
                do {
                    let response = try await controller.POST()
                    print(response)
                    await MainActor.run {
                        onLoggedOut()
                    }
                } catch {
                    print("Logout error:", error)
                }
            }
        }
    }
}

#Preview {
    LogOutView()
}
