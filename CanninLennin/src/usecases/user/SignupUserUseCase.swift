//
//  SignupUserUseCase.swift
//  CanninLennin
//
//  Created by Lennin Sabogal on 20/11/25.
//

import Foundation

struct SignupUserUseCase {
    private let userRepo: UserRepository
    private let userFactory: UserFactory
    private let presenter: UserResponseFormatter
    
    init(){
        self.userRepo = UserRepository()
        self.userFactory = UserFactory()
        self.presenter = UserResponseFormatter()
    }
    
    public func execute(request: UserRequestModel) async throws -> UserResponseModel {
        do {
            let currentUser = try await userRepo.getInfo()
            
            if !currentUser.uid.isEmpty {
                return presenter.prepareFailView(response: "A user is already logged in")
            }
            
            let userEntity = userFactory.createEntity(from: request)
            
            if !userEntity.emailIsValid() {
                return presenter.prepareFailView(response: "The email is not valid, please respect the guidelines")
            }
            
            if !userEntity.passwordIsValid() {
                return presenter.prepareFailView(response: "The password is not valid, please respect the guidelines")
            }
            
            let signupResult = try await userRepo.create(
                email: userEntity.email,
                password: userEntity.password
            )
            
            if signupResult[0] == "ERROR" {
                return presenter.prepareFailView(response: signupResult[1])
            }
            
            return presenter.prepareSuccessView(
                response: userFactory.createResponse(from: userEntity)
            )
            
        } catch {
            return presenter.prepareFailView(response: "It wasn't possible to sign up the user")
        }
    }
}
