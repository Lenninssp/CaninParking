//
//  GetUserUseCase.swift
//  CanninLennin
//
//  Created by Lennin Sabogal on 20/11/25.
//

import Foundation

struct GetUserUseCase {
    private let userRepo: UserRepository
    private let userFactory: UserFactory
    private let presenter: UserResponseFormatter
    
    init(){
        self.userRepo = UserRepository()
        self.userFactory = UserFactory()
        self.presenter = UserResponseFormatter()
    }
    
    public func execute() async throws -> UserResponseModel {
        do {
            let userInfo = userFactory.createEntity(from: try await userRepo.getInfo())
            return presenter.prepareSuccessView(
                response: userFactory.createResponse(from: userInfo)
            )
        } catch {
            return presenter.prepareFailView(response: "it wasn't possible to get the user information")
        }
        
    }
}
