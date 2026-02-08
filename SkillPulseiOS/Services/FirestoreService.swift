//
//  FirestoreService.swift
//  SkillPulse
//
//  Phase 2 - Real Firestore Database Implementation
//  Handles all task CRUD operations with Firebase Firestore
//

import Foundation
import FirebaseFirestore
import Combine

/// Firestore Service for Task Management
/// Handles Create, Read, Update, Delete operations for tasks
class FirestoreService: ObservableObject {
    // Singleton instance
    static let shared = FirestoreService()
    
    // MARK: - Properties
    
    private let db = Firestore.firestore()
    private let tasksCollection = "tasks"
    private let itemsLimit = 50
    
    /// Published array of tasks
    @Published var tasks: [Task] = []
    
    /// Loading state
    @Published var isLoading: Bool = false
    
    /// Error message
    @Published var errorMessage: String?
    
    // MARK: - Initialization
    
    private init() {
        print("📦 FirestoreService initialized (Phase 2 - Real Firebase)")
    }
    
    // MARK: - Load Tasks
    
    /// Load tasks for the current user
    /// - Parameter userEmail: Current user's email
    /// - Returns: Array of tasks or error
    func loadTasks(for userEmail: String) async throws -> [Task] {
        isLoading = true
        errorMessage = nil
        
        do {
            let snapshot = try await db.collection(tasksCollection)
                .whereField("userId", isEqualTo: userEmail)
                .order(by: "id", descending: true)
                .limit(to: itemsLimit)
                .getDocuments()
            
            var loadedTasks: [Task] = []
            
            for document in snapshot.documents {
                if let task = Task(document: document) {
                    loadedTasks.append(task)
                }
            }
            
            // Update published property on main thread
            await MainActor.run {
                self.tasks = loadedTasks
                self.isLoading = false
            }
            
            print("✅ Loaded \(loadedTasks.count) tasks for \(userEmail)")
            return loadedTasks
            
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
            print("❌ Error loading tasks: \(error.localizedDescription)")
            throw FirestoreError.loadFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Add Task
    
    /// Add a new task to Firestore
    /// - Parameters:
    ///   - description: Task description
    ///   - startTime: Start time in HH:mm format
    ///   - endTime: End time in HH:mm format
    ///   - userEmail: Current user's email
    /// - Throws: `FirestoreError.invalidData` if description is empty
    /// - Throws: `FirestoreError.addFailed` if Firestore operation fails
    func addTask(
        description: String,
        startTime: String,
        endTime: String,
        for userEmail: String
    ) async throws {
        guard !description.isEmpty else {
            throw FirestoreError.invalidData("Description cannot be empty")
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Generate task ID based on date
            let taskId = try await generateTaskId(startTime: startTime)
            
            // Create timestamp (ISO 8601 format)
            let timestamp = ISO8601DateFormatter().string(from: Date())
            
            // Create task dictionary
            let taskData: [String: Any] = [
                "id": taskId,
                "userId": userEmail,
                "description": description,
                "timestamp": timestamp,
                "startTime": startTime,
                "endTime": endTime
            ]
            
            // Add to Firestore using taskId as document ID
            try await db.collection(tasksCollection)
                .document(taskId)
                .setData(taskData)
            
            await MainActor.run {
                self.isLoading = false
            }
            
            print("✅ Task added successfully: \(taskId)")
            
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
            print("❌ Error adding task: \(error.localizedDescription)")
            throw FirestoreError.addFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Update Task
    
    /// Update an existing task
    /// - Parameters:
    ///   - taskId: Task ID to update
    ///   - description: New description
    ///   - startTime: New start time
    ///   - endTime: New end time
    /// - Throws: `FirestoreError.invalidData` if description is empty
    /// - Throws: `FirestoreError.taskNotFound` if task doesn't exist
    /// - Throws: `FirestoreError.updateFailed` if Firestore operation fails
    func updateTask(
        taskId: String,
        description: String,
        startTime: String,
        endTime: String
    ) async throws {
        guard !description.isEmpty else {
            throw FirestoreError.invalidData("Description cannot be empty")
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Find document with matching taskId
            let snapshot = try await db.collection(tasksCollection)
                .whereField("id", isEqualTo: taskId)
                .getDocuments()
            
            guard let document = snapshot.documents.first else {
                throw FirestoreError.taskNotFound
            }
            
            // Update fields
            let updates: [String: Any] = [
                "description": description,
                "startTime": startTime,
                "endTime": endTime
            ]
            
            try await db.collection(tasksCollection)
                .document(document.documentID)
                .updateData(updates)
            
            await MainActor.run {
                self.isLoading = false
            }
            
            print("✅ Task updated successfully: \(taskId)")
            
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
            print("❌ Error updating task: \(error.localizedDescription)")
            throw FirestoreError.updateFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Delete Task
    
    /// Delete a task from Firestore
    /// - Parameter taskId: Task ID to delete
    /// - Throws: `FirestoreError.taskNotFound` if task doesn't exist
    /// - Throws: `FirestoreError.deleteFailed` if Firestore operation fails
    func deleteTask(taskId: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            // Find document with matching taskId
            let snapshot = try await db.collection(tasksCollection)
                .whereField("id", isEqualTo: taskId)
                .getDocuments()
            
            guard let document = snapshot.documents.first else {
                throw FirestoreError.taskNotFound
            }
            
            // Delete the document
            try await db.collection(tasksCollection)
                .document(document.documentID)
                .delete()
            
            await MainActor.run {
                self.isLoading = false
            }
            
            print("✅ Task deleted successfully: \(taskId)")
            
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
            print("❌ Error deleting task: \(error.localizedDescription)")
            throw FirestoreError.deleteFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Generate a unique task ID in format YYYYMMDD###
    /// Example: 20260207001, 20260207002, etc.
    private func generateTaskId(startTime: String) async throws -> String {
        // Get current date in YYYYMMDD format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let datePrefix = dateFormatter.string(from: Date())
        
        // Query all tasks to find the highest number for today
        let snapshot = try await db.collection(tasksCollection)
            .order(by: "id", descending: true)
            .getDocuments()
        
        var maxNumber = 0
        
        for document in snapshot.documents {
            if let id = document.data()["id"] as? String,
               id.hasPrefix(datePrefix) {
                // Extract number part after date prefix
                let numberString = String(id.dropFirst(datePrefix.count))
                if let number = Int(numberString), number > maxNumber {
                    maxNumber = number
                }
            }
        }
        
        // Generate next ID with 3-digit padding
        let nextNumber = maxNumber + 1
        let taskId = String(format: "%@%03d", datePrefix, nextNumber)
        
        return taskId
    }
}

// MARK: - Firestore Errors

enum FirestoreError: LocalizedError {
    case loadFailed(String)
    case addFailed(String)
    case updateFailed(String)
    case deleteFailed(String)
    case taskNotFound
    case invalidData(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .loadFailed(let message):
            return "Failed to load tasks: \(message)"
        case .addFailed(let message):
            return "Failed to add task: \(message)"
        case .updateFailed(let message):
            return "Failed to update task: \(message)"
        case .deleteFailed(let message):
            return "Failed to delete task: \(message)"
        case .taskNotFound:
            return "Task not found"
        case .invalidData(let message):
            return "Invalid data: \(message)"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}
