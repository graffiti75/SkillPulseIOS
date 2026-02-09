//
//  TaskRowView.swift
//  SkillPulse
//
//  Phase 3 - Task row component for list display
//

import SwiftUI

struct TaskRowView: View {
    let task: SkillTask
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Task Description
            Text(task.description)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            // Time Range (if available)
            if task.hasTimeRange {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(formatTimeRange(task.startTime, task.endTime))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Task ID (small, subtle)
            Text("ID: \(task.id)")
                .font(.caption2)
                .foregroundColor(.secondary.opacity(0.6))
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Helper Functions
private func formatDate(_ isoString: String) -> String {
    guard let date = Date.fromISO8601String(isoString) else {
        return ""
    }
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter.string(from: date)
}

private func formatTimeRange(_ startISO: String, _ endISO: String) -> String {
    guard let startDate = Date.fromISO8601String(startISO),
          let endDate = Date.fromISO8601String(endISO) else {
        return "\(startISO) - \(endISO)" // Fallback: just show raw strings
    }
    
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    
    let startTime = formatter.string(from: startDate)
    let endTime = formatter.string(from: endDate)
    
    return "\(startTime) - \(endTime)"
}

// MARK: - Preview
#Preview("Task with Time") {
    List {
        TaskRowView(task: SkillTask.sampleTasks[0])
        TaskRowView(task: SkillTask.sampleTasks[1])
    }
}

#Preview("Task without Time") {
    List {
        TaskRowView(task: SkillTask.sampleTasks[2])
    }
}
