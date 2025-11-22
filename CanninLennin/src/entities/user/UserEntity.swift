//
//  UserEntity.swift
//  CanninLennin
//
//  Created by Lennin Sabogal on 20/11/25.
//

import Foundation

struct UserEntity {
    let uid: String
    let email: String
    let password: String
    
    init(uid: String, email: String ){
        self.uid = uid
        self.email = email
        self.password = ""
    }
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
        self.uid = ""
    }
    
    func emailIsValid() -> Bool{
        let emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
        if self.email.wholeMatch(of: emailRegex) != nil {
            return true
        } else {
            return false
        }
    }
    
    func passwordIsValid() -> Bool{
        let passwordRegex = /^(?=.*[A-Za-z])(?=.*\d).{8,}$/
        if self.password.wholeMatch(of: passwordRegex) != nil {
            return true
        } else {
            return false
        }
    }
}
