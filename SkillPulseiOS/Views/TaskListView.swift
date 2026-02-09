//
//  TaskListView.swift
//  SkillPulse
//
//  Phase 4.1 - Added Date Filtering Feature
//

import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var authService: AuthenticationService
    @StateObject private var firestoreService = FirestoreService.shared
    
    @State private var tasks: [SkillTask] = []
    @State private var allTasks: [SkillTask] = [] // Store all tasks for filtering
    @State private var isLoading: Bool = false
    @State private var alertItem: AlertItem?
    @State private var showAddTask: Bool = false
    @State private var taskToEdit: SkillTask?
    @State private var taskToDelete: SkillTask?
    @State private var showDeleteConfirmation: Bool = false
    
    // Phase 4.1 - Date Filtering
    @State private var showFilterOptions: Bool = false
    @State private var selectedFilterDate: Date? = nil
    @State private var isFilterActive: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // Filter bar (Phase 4.1)
                    if showFilterOptions {
                        filterBar
                    }
                    
                    // Task list or empty state
                    if tasks.isEmpty && !isLoading {
                        emptyStateView.frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        taskListContent
                    }
                }
                
                if isLoading {
                    LoadingView(message: "Loading tasks...")
                }
            }
            .navigationTitle("SkillPulse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    userInfoButton
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        filterButton
                        addButton
                    }
                }
            }
            .sheet(isPresented: $showAddTask) {
                AddTaskView(onTaskAdded: {
                    loadTasks()
                })
            }
            .sheet(item: $taskToEdit) { task in
                EditTaskView(task: task, onTaskUpdated: {
                    loadTasks()
                })
            }
            .alert(item: $alertItem) { alertItem in
                alertItem.alert
            }
            .confirmationDialog(
                "Delete Task",
                isPresented: $showDeleteConfirmation,
                presenting: taskToDelete
            ) { task in
                Button("Delete", role: .destructive) {
                    deleteTask(task)
                }
                Button("Cancel", role: .cancel) {
                    taskToDelete = nil
                }
            } message: { task in
                Text("Are you sure you want to delete '\(task.description)'?")
            }
            .onAppear {
                loadTasks()
            }
        }
    }
    
    // MARK: - View Components
    
    // Phase 4.1 - Filter Bar (Fixed UI)
    private var filterBar: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                // Date Picker (compact style)
                DatePicker(
                    "",
                    selection: Binding(
                        get: { selectedFilterDate ?? Date() },
                        set: { selectedFilterDate = $0 }
                    ),
                    displayedComponents: [.date]
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                
                Spacer()
                
                // Apply Filter Button
                Button(action: applyFilter) {
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            }
            
            // Clear Filter Button (if filter is active)
            if isFilterActive {
                Button(action: clearFilter) {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark.circle.fill")
                        Text("Clear Filter")
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    // Phase 4.1 - Filter Button
    private var filterButton: some View {
        Button(action: {
            withAnimation {
                showFilterOptions.toggle()
                if !showFilterOptions {
                    clearFilter()
                }
            }
        }) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: showFilterOptions ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    .font(.title2)
                    .foregroundColor(showFilterOptions ? .blue : .primary)
                
                // Badge when filter is active
                if isFilterActive {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .offset(x: 4, y: 0)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet.clipboard")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray)
            
            Text(isFilterActive ? "No Tasks Found" : "No Tasks Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(isFilterActive ? "Try a different date" : "Tap + to create your first task")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var taskListContent: some View {
        List {
            ForEach(tasks) { task in
                TaskRowView(task: task)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        taskToEdit = task
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            taskToDelete = task
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
        .refreshable {
            loadTasks()
        }
    }
    
    private var userInfoButton: some View {
        Menu {
            Text(authService.currentUserEmail)
            
            Divider()
            
            Button(role: .destructive) {
                handleSignOut()
            } label: {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.blue)
                Text(getUsernameFromEmail())
                    .font(.headline)
                    .foregroundColor(.primary)
            }
        }
    }
    
    private var addButton: some View {
        Button(action: {
            showAddTask = true
        }) {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
        }
    }
    
    // MARK: - Phase 4.1 - Filter Methods
    
    private func applyFilter() {
        guard let filterDate = selectedFilterDate else { return }
        
        isFilterActive = true
        
        // Format the date to match ISO 8601 format (YYYY-MM-DD)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: filterDate)
        
        // Filter tasks that contain this date in their startTime
        tasks = allTasks.filter { task in
            task.startTime.contains(dateString)
        }
        
        print("📅 Filtered by date: \(dateString), found \(tasks.count) tasks")
    }
    
    private func clearFilter() {
        withAnimation {
            isFilterActive = false
            selectedFilterDate = nil
            tasks = allTasks
        }
        print("🔄 Filter cleared, showing all \(tasks.count) tasks")
    }
    
    // MARK: - Helper Methods
    
    private func getUsernameFromEmail() -> String {
        let email = authService.currentUserEmail
        if let atIndex = email.firstIndex(of: "@") {
            return String(email[..<atIndex])
        }
        return email
    }
    
    private func loadTasks() {
        guard !authService.currentUserEmail.isEmpty else {
            print("⚠️ No user email available")
            return
        }
        
        isLoading = true
        
        Task {
            do {
                let loadedTasks = try await firestoreService.loadTasks(
                    for: authService.currentUserEmail
                )
                
                await MainActor.run {
                    self.allTasks = loadedTasks
                    
                    // Apply filter if active, otherwise show all
                    if isFilterActive {
                        applyFilter()
                    } else {
                        self.tasks = loadedTasks
                    }
                    
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.alertItem = AlertItem.error(error.localizedDescription)
                }
            }
        }
    }
    
    private func deleteTask(_ task: SkillTask) {
        Task {
            do {
                try await firestoreService.deleteTask(taskId: task.id)
                
                await MainActor.run {
                    // Remove from both arrays
                    allTasks.removeAll { $0.id == task.id }
                    tasks.removeAll { $0.id == task.id }
                    alertItem = AlertItem.success("Task deleted successfully")
                }
            } catch {
                await MainActor.run {
                    alertItem = AlertItem.error(error.localizedDescription)
                }
            }
        }
    }
    
    private func handleSignOut() {
        do {
            try authService.signOut()
            // Navigation happens automatically via auth state listener
        } catch {
            alertItem = AlertItem.error(error.localizedDescription)
        }
    }
}

// MARK: - Preview
#Preview {
    TaskListView()
        .environmentObject(AuthenticationService.shared)
}
