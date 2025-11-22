//
//  LogoutUserUseCase.swift
//  CanninLennin
//
//  Created by Lennin Sabogal on 20/11/25.
//

import Foundation

struct LogoutUserUseCase {
    private let userRepo: UserRepository
    private let userFactory: UserFactory
    private let presenter: UserResponseFormatter
    
    init(){
        self.userRepo = UserRepository()
        self.userFactory = UserFactory()
        self.presenter = UserResponseFormatter()
    }
    
    public func execute() async throws -> [String] {
        do {
            let currentUser = try await userRepo.getInfo()
            
            if currentUser.uid.isEmpty {
                return ["ERROR", "No user is logged in"]
            }
            
            
            let logoutResult = try await userRepo.signOut()
            
            if logoutResult[0] == "ERROR" {
                return logoutResult
            }
            
            return
                ["SUCCESS", "The user was logged out successfully"]
            
        } catch {
            return ["ERROR", "It wasn't possible to log in the user"]
        }
    }
}
