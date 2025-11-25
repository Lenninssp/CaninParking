//
//  CanninLenninApp.swift
//  CanninLennin
//
//  Created by Lennin Sabogal on 28/10/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      FirebaseApp.configure();
    return true
  }
}

@main
struct CanninLenninApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            AuthenticationSwitcher()
        }
    }
}
