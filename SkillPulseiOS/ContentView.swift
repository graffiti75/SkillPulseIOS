//
//  ContentView.swift
//  SkillPulseiOS
//
//  Created by graffiti75 on 07/02/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthenticationService
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                // User is logged in - show main app
                TaskListView()
            } else {
                // User is not logged in - show login screen
                LoginView()
            }
        }
        .onAppear {
            // Check if user is already logged in when app starts
            authService.checkAuthenticationState()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationService.shared)
}
