//
//  LoginUserControlller.swift
//  CanninLennin
//
//  Created by Lennin Sabogal on 20/11/25.
//

import Foundation

struct LoginUserController {
    let useCase: LoginUserUseCase
    
    init(){
        self.useCase = LoginUserUseCase()
    }
    public func POST(request: UserRequestModel) async throws -> UserResponseModel {
        return await useCase.execute(request: request)
    }
}
