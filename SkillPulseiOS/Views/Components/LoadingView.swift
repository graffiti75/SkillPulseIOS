//
//  LoadingView.swift
//  SkillPulse
//
//  Reusable loading indicator component
//

import SwiftUI

struct LoadingView: View {
    var message: String = "Loading..."
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            // Loading card
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                
                Text(message)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding(40)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 10)
        }
    }
}

// MARK: - Preview
#Preview("Loading") {
    LoadingView()
}

#Preview("Loading with Custom Message") {
    LoadingView(message: "Signing in...")
}
