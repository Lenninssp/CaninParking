//
//  UserResponse.swift
//  CanninLennin
//
//  Created by Lennin Sabogal on 20/11/25.
//

import Foundation

struct UserResponseModel {
    let uid: String
    let email: String
    let message: String?
        
    init(message: String) {
        self.message = message
        self.email = ""
        self.uid = ""
    }
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
        self.message = nil
    }
    
    func isSuccess() -> Bool {
        message == nil && !uid.isEmpty
    }

    
}
