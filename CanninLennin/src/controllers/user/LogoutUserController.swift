//
//  LogoutUserController.swift
//  CanninLennin
//
//  Created by Lennin Sabogal on 20/11/25.
//

import Foundation

struct LogoutUserController {
    let useCase: LogoutUserUseCase
    
    init(){
        self.useCase = LogoutUserUseCase()
    }
    public func POST() async throws -> [String] {
        return try await useCase.execute()
    }
}
