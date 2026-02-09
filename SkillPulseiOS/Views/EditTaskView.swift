//
//  EditTaskView.swift
//  SkillPulse
//
//  Phase 3 - Edit Task View
//

import SwiftUI

struct EditTaskView: View {
    @Environment(\.dismiss) var dismiss
    
    let task: SkillTask
    var onTaskUpdated: () -> Void
    
    @State private var description: String = ""
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    @State private var isLoading: Bool = false
    @State private var alertItem: AlertItem?
    
    // Phase 4.3 - Suggestions
    var suggestions: [String] = []
    @State private var showSuggestions: Bool = false
    @State private var filteredSuggestions: [String] = []
    
    @FocusState private var isDescriptionFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    Section("Task Details") {
                        TextField("Description", text: $description, axis: .vertical)
                            .lineLimit(3...6)
                            .focused($isDescriptionFocused)
                            .onChange(of: description) { oldValue, newValue in
                                updateSuggestions(for: newValue)
                            }
                        
                        // Suggestions dropdown
                        if showSuggestions && !filteredSuggestions.isEmpty {
                            suggestionsDropdown
                                .padding(.top, 8)
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
                    
                    Section {
                        HStack {
                            Text("Task ID:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(task.id)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if isLoading {
                    LoadingView(message: "Updating task...")
                }
            }
            .navigationTitle("Edit Task")
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
                loadTaskData()
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
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Setup
    
    private func loadTaskData() {
        description = task.description
        
        // Parse time strings (HH:mm format) to Date objects
        if let start = parseDateTimeString(task.startTime) {
            startTime = start
        }
        
        if let end = parseDateTimeString(task.endTime) {
            endTime = end
        }
    }
    
    private func parseDateTimeString(_ dateTimeString: String) -> Date? {
        guard !dateTimeString.isEmpty else { return nil }
        
        // Try ISO 8601 format first (from Android/new iOS)
        if let date = Date.fromISO8601String(dateTimeString) {
            return date
        }
        
        // Fallback to HH:mm format (for old iOS data)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if let time = formatter.date(from: dateTimeString) {
            let calendar = Calendar.current
            let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
            return calendar.date(
                bySettingHour: timeComponents.hour ?? 0,
                minute: timeComponents.minute ?? 0,
                second: 0,
                of: Date()
            )
        }
        
        return nil
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
        isDescriptionFocused = false
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
            
            try await FirestoreService.shared.updateTask(
                taskId: task.id,
                description: description,
                startTime: startTimeString,
                endTime: endTimeString
            )
            
            await MainActor.run {
                isLoading = false
                onTaskUpdated()
                dismiss()
            }
        } catch {
            await MainActor.run {
                isLoading = false
                alertItem = AlertItem.error(error.localizedDescription)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    EditTaskView(
        task: SkillTask.sample,
        onTaskUpdated: {}
    )
}
