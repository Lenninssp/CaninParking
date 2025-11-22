//
//  SignupUserController.swift
//  CanninLennin
//
//  Created by Lennin Sabogal on 20/11/25.
//

import Foundation

struct SignupUserController{
    let useCase: SignupUserUseCase
    
    init(){
        self.useCase = SignupUserUseCase()
    }
    public func POST(request: UserRequestModel) async throws -> UserResponseModel {
        return try await useCase.execute(request: request)
    }
    
}
