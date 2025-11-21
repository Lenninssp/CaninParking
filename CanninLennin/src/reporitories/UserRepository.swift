//
//  UserRepository.swift
//  CanninLennin
//
//  Created by Lennin Sabogal on 20/11/25.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth



struct UserRepository {
    
    var firebaseAuth: Auth
    
    public init() {
        self.firebaseAuth = Auth.auth()
    }
    
    public func getInfo() -> UserPersistence {
        guard let user = firebaseAuth.currentUser else {
            return UserPersistence(uid: "", email: "")
        }
        
        return UserPersistence(
            uid: user.uid,
            email: user.email ?? ""
        )
    }
    
    // taken from: https://firebase.google.com/docs/auth/ios/custom-auth?_gl=1*1u58ey1*_up*MQ..*_ga*MTQ1NTU1MTI3MC4xNzYzNjkzMjE4*_ga_CW55HF8NVT*czE3NjM2OTMyMTgkbzEkZzAkdDE3NjM2OTMyMTgkajYwJGwwJGgw#swift_1
 
    public func signOut() -> [String] {
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            return ["ERROR", "Error signing out: \(signOutError)"]
        }
        return ["SUCCESS", "The user was successfully signed out"]
    }
    
    public func authentify(email: String, password: String) -> [String] {
        var future: [String] = [""]
        firebaseAuth.signIn(withEmail: email, password: password){ authResult, error in
            guard let user = authResult?.user, error == nil else {
                return future = ["ERROR", "There was an error authenticating the user: \(error?.localizedDescription ?? "")"]
                         }
            print("\(user.email!) created")
            future = ["SUCCESS", "The user was successfully created"]
        }
        return future
    }
    
    public func create(email: String, password: String) -> [String]{
        var future: [String] = [""]
        firebaseAuth.createUser(withEmail: email, password: password) { authResult, error in
            guard let user = authResult?.user, error == nil else {
                return future = ["ERROR", "There was an error creating the user: \(error?.localizedDescription ?? "")"]
                         }
            print("\(user.email!) created")
            future = ["SUCCESS", "The user was successfully created"]
        }
        return future
    }
}
