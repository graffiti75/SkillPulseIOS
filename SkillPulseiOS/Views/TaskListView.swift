//
//  TaskListView.swift
//  SkillPulse
//
//  Phase 3 - Real Task List View with Firestore Integration
//  Replaces Phase 1.5 placeholder
//

import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var authService: AuthenticationService
    @StateObject private var firestoreService = FirestoreService.shared
    
    @State private var tasks: [SkillTask] = []
    @State private var isLoading: Bool = false
    @State private var alertItem: AlertItem?
    @State private var showAddTask: Bool = false
    @State private var taskToEdit: SkillTask?
    @State private var taskToDelete: SkillTask?
    @State private var showDeleteConfirmation: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if tasks.isEmpty && !isLoading {
                    emptyStateView
                } else {
                    taskListContent
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
                    addButton
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
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet.clipboard")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray)
            
            Text("No Tasks Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tap + to create your first task")
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
                    self.tasks = loadedTasks
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
                    // Remove from local array
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
