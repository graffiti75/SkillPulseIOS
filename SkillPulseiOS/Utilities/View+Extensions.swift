//
//  View+Extensions.swift
//  SkillPulse
//
//  Reusable view modifiers and extensions
//

import SwiftUI

// MARK: - Custom View Modifiers
extension View {
    /// Standard card style used throughout the app
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
    
    /// Primary button style
    func primaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
    }
    
    /// Secondary button style
    func secondaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
    }
    
    /// Loading overlay modifier
    func loadingOverlay(isLoading: Bool) -> some View {
        self.overlay(
            Group {
                if isLoading {
                    LoadingView()
                }
            }
        )
    }
    
    /// Hide keyboard on tap
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
    
    /// Add a dismissible keyboard toolbar
    func keyboardDismissToolbar() -> some View {
        self.toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    hideKeyboard()
                }
            }
        }
    }
}

// MARK: - Alert Item
struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let dismissButton: Alert.Button
    
    init(title: String, message: String, dismissButton: Alert.Button = .default(Text("OK"))) {
        self.title = title
        self.message = message
        self.dismissButton = dismissButton
    }
    
    var alert: Alert {
        Alert(
            title: Text(title),
            message: Text(message),
            dismissButton: dismissButton
        )
    }
}

// MARK: - Common Alert Items
extension AlertItem {
    static func error(_ message: String) -> AlertItem {
        AlertItem(
            title: "Error",
            message: message
        )
    }
    
    static func success(_ message: String) -> AlertItem {
        AlertItem(
            title: "Success",
            message: message
        )
    }
    
    static func confirmation(
        title: String,
        message: String,
        primaryAction: @escaping () -> Void
    ) -> AlertItem {
        AlertItem(
            title: title,
            message: message,
            dismissButton: .default(Text("Confirm")) {
                primaryAction()
            }
        )
    }
}

// MARK: - TextField Styles
struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
    }
}

extension View {
    func roundedTextFieldStyle() -> some View {
        self.textFieldStyle(RoundedTextFieldStyle())
    }
}
