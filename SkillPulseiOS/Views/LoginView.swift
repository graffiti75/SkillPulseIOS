//
//  LoginView.swift
//  SkillPulse
//
//  Phase 3 - Real Login View with Firebase Authentication
//  Replaces Phase 1.5 placeholder
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthenticationService
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var alertItem: AlertItem?
    @State private var isLoading: Bool = false
    
    // Focus management
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 30) {
                        // App Logo/Title Section
                        headerSection
                        
                        // Input Fields Section
                        inputFieldsSection
                        
                        // Buttons Section
                        buttonsSection
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 60)
                }
                
                // Loading overlay
                if isLoading {
                    LoadingView(message: "Please wait...")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert(item: $alertItem) { alertItem in
                alertItem.alert
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
            
            Text("SkillPulse")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Task Management")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var inputFieldsSection: some View {
        VStack(spacing: 15) {
            // Email Field
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .focused($focusedField, equals: .email)
                .onSubmit {
                    focusedField = .password
                }
            
            // Password Field
            HStack {
                Group {
                    if showPassword {
                        TextField("Password", text: $password)
                    } else {
                        SecureField("Password", text: $password)
                    }
                }
                .textContentType(.password)
                .focused($focusedField, equals: .password)
                .onSubmit {
                    focusedField = nil
                    handleLogin()
                }
                
                Button(action: {
                    showPassword.toggle()
                }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
    
    private var buttonsSection: some View {
        VStack(spacing: 12) {
            // Sign Up Button
            Button(action: handleSignUp) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isLoading)
            
            // Log In Button
            Button(action: handleLogin) {
                Text("Log In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
            }
            .disabled(isLoading)
        }
    }
    
    // MARK: - Actions
    
    private func handleSignUp() {
        // Dismiss keyboard
        focusedField = nil
        
        // Validate fields
        guard validateFields() else { return }
        
        isLoading = true
        
        Task {
            do {
                try await authService.signUp(email: email, password: password)
                
                await MainActor.run {
                    isLoading = false
                    alertItem = AlertItem.success("Account created successfully! You can now log in.")
                    // Clear password after successful signup
                    password = ""
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertItem = AlertItem.error(error.localizedDescription)
                }
            }
        }
    }
    
    private func handleLogin() {
        // Dismiss keyboard
        focusedField = nil
        
        // Validate fields
        guard validateFields() else { return }
        
        isLoading = true
        
        Task {
            do {
                try await authService.signIn(email: email, password: password)
                
                await MainActor.run {
                    isLoading = false
                    // Navigation happens automatically via auth state listener
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertItem = AlertItem.error(error.localizedDescription)
                }
            }
        }
    }
    
    private func validateFields() -> Bool {
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertItem = AlertItem.error("Email cannot be empty")
            return false
        }
        
        if password.isEmpty {
            alertItem = AlertItem.error("Password cannot be empty")
            return false
        }
        
        return true
    }
}

// MARK: - Preview
#Preview {
    LoginView()
        .environmentObject(AuthenticationService.shared)
}
