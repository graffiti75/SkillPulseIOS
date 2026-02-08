//
//  LoginView.swift
//  SkillPulse
//
//  Phase 1.5 - Simple placeholder to make app runnable
//  This will be replaced with full implementation in Phase 3
//

import SwiftUI

/// Simple Login View - Minimal implementation to make app run
/// PHASE 1.5: This is a placeholder. Real implementation comes in Phase 3.
struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // App Logo/Title
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
                .padding(.top, 60)
                
                Spacer()
                
                // Placeholder message
                VStack(spacing: 15) {
                    Text("Phase 1.5 - Runnable Preview")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("The login functionality will be added in Phase 2 & 3")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Simple input fields (non-functional for now)
                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal, 30)
                
                // Placeholder buttons
                VStack(spacing: 12) {
                    Button(action: {
                        print("Sign Up tapped (Phase 1.5 - not yet functional)")
                    }) {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        print("Log In tapped (Phase 1.5 - not yet functional)")
                    }) {
                        Text("Log In")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Phase indicator
                Text("✅ App is running successfully!")
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Preview
#Preview {
    LoginView()
}
