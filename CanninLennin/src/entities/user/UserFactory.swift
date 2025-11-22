//
//  UserFactory.swift
//  CanninLennin
//
//  Created by Lennin Sabogal on 20/11/25.
//

import Foundation

struct UserFactory {
    func createEntity(from request: UserRequestModel) -> UserEntity{
        return UserEntity(email: request.email, password: request.password)
    }
    
    func createEntity(from persistence: UserPersistence) -> UserEntity{
        return UserEntity(uid: persistence.uid, email: persistence.email)
    }
    
    func createResponse(from entity: UserEntity) -> UserResponseModel{
        return UserResponseModel(uid: entity.uid, email: entity.email)
    }
}
