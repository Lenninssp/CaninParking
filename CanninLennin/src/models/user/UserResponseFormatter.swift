//
//  UserResponseFormatter.swift
//  CanninLennin
//
//  Created by Lennin Sabogal on 20/11/25.
//

import Foundation

struct UserResponseFormatter {
    func prepareSuccessView(response: UserResponseModel) -> UserResponseModel {
        return response
    }
    
    func prepareFailView(response: String) -> UserResponseModel {
        print("There was an error:  \(response)")
        return UserResponseModel(message: response)
    }
}
