//
//  AuthenticationService.swift
//  SkillPulse
//
//  Phase 2 - Real Firebase Authentication Implementation
//  This replaces the Phase 1.5 stub version
//

import Foundation
import Combine
import FirebaseAuth

/// Real Authentication Service with Firebase Integration
/// Handles user authentication, session management, and state tracking
class AuthenticationService: ObservableObject {
    // Singleton instance
    static let shared = AuthenticationService()
    
    // MARK: - Published Properties
    
    /// Tracks if user is currently authenticated
    @Published var isAuthenticated: Bool = false
    
    /// Current user's email
    @Published var currentUserEmail: String = ""
    
    /// Current user's ID (UID from Firebase)
    @Published var currentUserId: String = ""
    
    /// Loading state for async operations
    @Published var isLoading: Bool = false
    
    /// Error message for display
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    private init() {
        print("🔐 AuthenticationService initialized (Phase 2 - Real Firebase)")
        setupAuthStateListener()
    }
    
    deinit {
        // Remove auth state listener when service is deallocated
        if let handler = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }
    
    // MARK: - Auth State Management
    
    /// Set up listener for Firebase auth state changes
    private func setupAuthStateListener() {
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.handleAuthStateChange(user: user)
            }
        }
    }
    
    /// Handle authentication state changes
    private func handleAuthStateChange(user: User?) {
        if let user = user {
            // User is signed in
            isAuthenticated = true
            currentUserId = user.uid
            currentUserEmail = user.email ?? ""
            print("✅ User authenticated: \(currentUserEmail)")
        } else {
            // User is signed out
            isAuthenticated = false
            currentUserId = ""
            currentUserEmail = ""
            print("🚪 User signed out")
        }
    }
    
    /// Check current authentication state
    func checkAuthenticationState() {
        let user = Auth.auth().currentUser
        handleAuthStateChange(user: user)
    }
    
    // MARK: - Sign Up
    
    /// Create a new user account with email and password
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password (min 6 characters)
    /// - Returns: Success or error
    func signUp(email: String, password: String) async throws {
        // Validate inputs
        guard !email.isEmpty, !password.isEmpty else {
            throw AuthError.emptyFields
        }
        
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }
        
        guard password.count >= 6 else {
            throw AuthError.passwordTooShort
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("✅ Sign up successful: \(result.user.email ?? "")")
            isLoading = false
        } catch let error as NSError {
            isLoading = false
            throw handleFirebaseError(error)
        }
    }
    
    // MARK: - Sign In
    
    /// Sign in existing user with email and password
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    /// - Returns: Success or error
    func signIn(email: String, password: String) async throws {
        // Validate inputs
        guard !email.isEmpty, !password.isEmpty else {
            throw AuthError.emptyFields
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("✅ Sign in successful: \(result.user.email ?? "")")
            isLoading = false
        } catch let error as NSError {
            isLoading = false
            throw handleFirebaseError(error)
        }
    }
    
    // MARK: - Sign Out
    
    /// Sign out the current user
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            print("👋 User signed out successfully")
        } catch let error as NSError {
            throw handleFirebaseError(error)
        }
    }
    
    // MARK: - Password Reset
    
    /// Send password reset email to user
    /// - Parameter email: User's email address
    func resetPassword(email: String) async throws {
        guard !email.isEmpty else {
            throw AuthError.emptyFields
        }
        
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            print("📧 Password reset email sent to: \(email)")
        } catch let error as NSError {
            throw handleFirebaseError(error)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Validate email format
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    /// Convert Firebase errors to custom AuthError
    private func handleFirebaseError(_ error: NSError) -> AuthError {
        guard let errorCode = AuthErrorCode(rawValue: error.code) else {
            return AuthError.unknown(error.localizedDescription)
        }
        
        switch errorCode {
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .invalidEmail:
            return .invalidEmail
        case .wrongPassword:
            return .wrongPassword
        case .userNotFound:
            return .userNotFound
        case .weakPassword:
            return .passwordTooShort
        case .networkError:
            return .networkError
        case .userDisabled:
            return .accountDisabled
        case .tooManyRequests:
            return .tooManyRequests
        default:
            return .unknown(error.localizedDescription)
        }
    }
}

// MARK: - Custom Auth Errors

enum AuthError: LocalizedError {
    case emptyFields
    case invalidEmail
    case passwordTooShort
    case emailAlreadyInUse
    case wrongPassword
    case userNotFound
    case accountDisabled
    case networkError
    case tooManyRequests
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .emptyFields:
            return "Please fill in all fields"
        case .invalidEmail:
            return "Please enter a valid email address"
        case .passwordTooShort:
            return "Password must be at least 6 characters"
        case .emailAlreadyInUse:
            return "This email is already registered"
        case .wrongPassword:
            return "Incorrect password"
        case .userNotFound:
            return "No account found with this email"
        case .accountDisabled:
            return "This account has been disabled"
        case .networkError:
            return "Network error. Please check your connection"
        case .tooManyRequests:
            return "Too many attempts. Please try again later"
        case .unknown(let message):
            return message
        }
    }
}
