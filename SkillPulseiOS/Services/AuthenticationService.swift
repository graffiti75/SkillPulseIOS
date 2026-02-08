//
//  AuthenticationService.swift
//  SkillPulse
//
//  Phase 1.5 - Stub version to make app runnable
//  This will be replaced with full implementation in Phase 2
//

import Foundation
import Combine

/// Stub Authentication Service - Minimal implementation to make app compile and run
/// PHASE 1.5: This is a placeholder. Real implementation comes in Phase 2.
class AuthenticationService: ObservableObject {
    // Singleton instance
    static let shared = AuthenticationService()
    
    // Published property to track authentication state
    @Published var isAuthenticated: Bool = false
    
    // Current user ID (empty for now)
    @Published var currentUserId: String = ""
    
    private init() {
        print("📱 AuthenticationService initialized (Phase 1.5 stub)")
    }
    
    /// Check if user is already authenticated
    /// PHASE 1.5: Does nothing for now
    func checkAuthenticationState() {
        print("🔍 Checking auth state... (stub - always returns false)")
        isAuthenticated = false
    }
    
    /// Sign in with email and password
    /// PHASE 1.5: Placeholder - will be implemented in Phase 2
    func signIn(email: String, password: String) async throws {
        print("🔐 Sign in called (stub - not yet implemented)")
        // Real implementation in Phase 2
    }
    
    /// Create new user account
    /// PHASE 1.5: Placeholder - will be implemented in Phase 2
    func signUp(email: String, password: String) async throws {
        print("📝 Sign up called (stub - not yet implemented)")
        // Real implementation in Phase 2
    }
    
    /// Sign out current user
    /// PHASE 1.5: Placeholder - will be implemented in Phase 2
    func signOut() throws {
        print("👋 Sign out called (stub - not yet implemented)")
        // Real implementation in Phase 2
    }
}
