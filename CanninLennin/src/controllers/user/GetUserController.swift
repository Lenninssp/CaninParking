//
//  GetUserController.swift
//  CanninLennin
//
//  Created by Lennin Sabogal on 20/11/25.
//

import Foundation

struct GetUserController {
    let useCase: GetUserUseCase
    
    init(){
        self.useCase = GetUserUseCase()
    }
    public func POST() async throws -> UserResponseModel {
        return try await useCase.execute()
    }
}
