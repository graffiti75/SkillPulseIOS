//
//  SkillPulseiOSApp.swift
//  SkillPulseiOS
//
//  Created by graffiti75 on 07/02/26.
//

import SwiftUI
import FirebaseCore

@main
struct SkillPulseApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // State management for authentication
    @StateObject private var authService = AuthenticationService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
        }
    }
}

// MARK: - App Delegate for Firebase
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        print("✅ Firebase configured successfully")
        return true
    }
}
