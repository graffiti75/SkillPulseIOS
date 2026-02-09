//
//  AddTaskView.swift
//  SkillPulse
//
//  Phase 3 - Add Task View
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: AuthenticationService
    
    var onTaskAdded: () -> Void
    
    @State private var description: String = ""
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date().addingTimeInterval(3600) // 1 hour later
    @State private var isLoading: Bool = false
    @State private var alertItem: AlertItem?
    
    @FocusState private var isDescriptionFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    Section("Task Details") {
                        TextField("Description", text: $description, axis: .vertical)
                            .lineLimit(3...6)
                            .focused($isDescriptionFocused)
                    }
                    
                    Section("Time") {
                        DatePicker(
                            "Start Time",
                            selection: $startTime,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        
                        DatePicker(
                            "End Time",
                            selection: $endTime,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                }
                
                if isLoading {
                    LoadingView(message: "Creating task...")
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await handleSave()
                        }
                    }
                    .disabled(description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert(item: $alertItem) { alertItem in
                alertItem.alert
            }
            .onAppear {
                // Auto-focus description field
                isDescriptionFocused = true
            }
        }
    }
    
    // MARK: - Actions
    
    private func handleSave() async {
        // Validate
        guard !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertItem = AlertItem.error("Please enter a task description")
            return
        }
        
        // Validate time range
        guard endTime > startTime else {
            alertItem = AlertItem.error("End time must be after start time")
            return
        }
        
        isLoading = true
        
        do {
            // Convert to ISO 8601 datetime format
            let startTimeString = startTime.toISO8601String()
            let endTimeString = endTime.toISO8601String()
            
            try await FirestoreService.shared.addTask(
                description: description,
                startTime: startTimeString,
                endTime: endTimeString,
                for: authService.currentUserEmail
            )
            
            isLoading = false
            onTaskAdded()
            dismiss()
        } catch {
            isLoading = false
            alertItem = AlertItem.error(error.localizedDescription)
        }
    }
}

// MARK: - Preview
#Preview {
    AddTaskView(onTaskAdded: {})
        .environmentObject(AuthenticationService.shared)
}
