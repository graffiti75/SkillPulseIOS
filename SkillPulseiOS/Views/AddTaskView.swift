//
//  AddTaskView.swift
//  SkillPulse
//
//  Phase 4.3 - Added Task Suggestions Feature
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: AuthenticationService
    
    var onTaskAdded: () -> Void
    var suggestions: [String] = [] // Phase 4.3 - Task suggestions from previous tasks
    
    @State private var description: String = ""
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date().addingTimeInterval(3600) // 1 hour later
    @State private var isLoading: Bool = false
    @State private var alertItem: AlertItem?
    
    // Phase 4.3 - Suggestions
    @State private var showSuggestions: Bool = false
    @State private var filteredSuggestions: [String] = []
    
    @FocusState private var isDescriptionFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    // Phase 4.3 - Description with suggestions
                    Section("Task Details") {
                        VStack(alignment: .leading, spacing: 0) {
                            TextField("Description", text: $description, axis: .vertical)
                                .lineLimit(3...6)
                                .focused($isDescriptionFocused)
                                .onChange(of: description) { oldValue, newValue in
                                    updateSuggestions(for: newValue)
                                }
                            
                            // Suggestions dropdown RIGHT BELOW the text field
                            if showSuggestions && !filteredSuggestions.isEmpty {
                                suggestionsDropdown
                                    .padding(.top, 8)
                            }
                        }
                    }
                    
                    Section("Date & Time") {
                        DatePicker(
                            "Start",
                            selection: $startTime,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        
                        DatePicker(
                            "End",
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
    
    // MARK: - Phase 4.3 - Suggestions Dropdown
    
    private var suggestionsDropdown: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(filteredSuggestions.prefix(5), id: \.self) { suggestion in
                    Button(action: {
                        selectSuggestion(suggestion)
                    }) {
                        HStack {
                            Text(suggestion)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Image(systemName: "arrow.up.left")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    
                    if suggestion != filteredSuggestions.prefix(5).last {
                        Divider()
                    }
                }
            }
        }
        .frame(maxHeight: 200)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Phase 4.3 - Suggestion Logic
    
    private func updateSuggestions(for text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Only show suggestions if user typed something
        guard !trimmed.isEmpty else {
            showSuggestions = false
            filteredSuggestions = []
            return
        }
        
        // Filter suggestions that START with the input text (case insensitive)
        // and are not exactly the same as current text
        filteredSuggestions = suggestions.filter { suggestion in
            suggestion.lowercased().hasPrefix(trimmed.lowercased()) &&
            suggestion.lowercased() != trimmed.lowercased()
        }
        
        showSuggestions = !filteredSuggestions.isEmpty
    }
    
    private func selectSuggestion(_ suggestion: String) {
        description = suggestion
        showSuggestions = false
        filteredSuggestions = []
        isDescriptionFocused = false // Dismiss keyboard
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
    AddTaskView(
        onTaskAdded: {},
        suggestions: [
            "Morning workout",
            "Team meeting",
            "Code review",
            "Grocery shopping",
            "Coffee break"
        ]
    )
    .environmentObject(AuthenticationService.shared)
}
