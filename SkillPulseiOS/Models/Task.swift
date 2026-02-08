//
//  Task.swift
//  SkillPulse
//
//  A task model for the SkillPulse app
//

import Foundation
import FirebaseFirestore

/// Represents a task in the SkillPulse app
struct Task: Identifiable, Codable, Equatable {
    /// Unique identifier for the task
    var id: String
    
    /// User ID who owns this task
    var userId: String
    
    /// Task description/title
    var description: String
    
    /// Timestamp when the task was created (ISO 8601 format)
    var timestamp: String
    
    /// Start time for the task (format: "HH:mm" or empty)
    var startTime: String
    
    /// End time for the task (format: "HH:mm" or empty)
    var endTime: String
    
    /// Default initializer
    init(
        id: String = UUID().uuidString,
        userId: String = "",
        description: String = "",
        timestamp: String = "",
        startTime: String = "",
        endTime: String = ""
    ) {
        self.id = id
        self.userId = userId
        self.description = description
        self.timestamp = timestamp
        self.startTime = startTime
        self.endTime = endTime
    }
    
    /// Create a Task from Firestore document
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        
        self.id = document.documentID
        self.userId = data["userId"] as? String ?? ""
        self.description = data["description"] as? String ?? ""
        self.timestamp = data["timestamp"] as? String ?? ""
        self.startTime = data["startTime"] as? String ?? ""
        self.endTime = data["endTime"] as? String ?? ""
    }
    
    /// Convert Task to dictionary for Firestore
    func toDictionary() -> [String: Any] {
        return [
            "userId": userId,
            "description": description,
            "timestamp": timestamp,
            "startTime": startTime,
            "endTime": endTime
        ]
    }
}

// MARK: - Computed Properties
extension Task {
    /// Check if task has valid time range
    var hasTimeRange: Bool {
        !startTime.isEmpty && !endTime.isEmpty
    }
    
    /// Get formatted time range string
    var timeRangeText: String {
        if hasTimeRange {
            return "\(startTime) - \(endTime)"
        }
        return ""
    }
    
    /// Check if task is valid (has description)
    var isValid: Bool {
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Sample Data (for previews and testing)
extension Task {
    /// Create sample tasks for SwiftUI previews
    static let sampleTasks: [Task] = [
        Task(
            id: UUID().uuidString,
            userId: "user123",
            description: "Complete iOS app conversion",
            timestamp: ISO8601DateFormatter().string(from: Date()),
            startTime: "09:00",
            endTime: "12:00"
        ),
        Task(
            id: UUID().uuidString,
            userId: "user123",
            description: "Review Firebase integration",
            timestamp: ISO8601DateFormatter().string(from: Date()),
            startTime: "14:00",
            endTime: "15:30"
        ),
        Task(
            id: UUID().uuidString,
            userId: "user123",
            description: "Write unit tests",
            timestamp: ISO8601DateFormatter().string(from: Date()),
            startTime: "",
            endTime: ""
        )
    ]
    
    /// Single sample task
    static var sample: Task {
        Task(
            id: UUID().uuidString,
            userId: "user123",
            description: "Sample task",
            timestamp: ISO8601DateFormatter().string(from: Date()),
            startTime: "10:00",
            endTime: "11:00"
        )
    }
}
