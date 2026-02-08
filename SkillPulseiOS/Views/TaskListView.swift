//
//  TaskListView.swift
//  SkillPulse
//
//  Phase 1.5 - Simple placeholder to make app runnable
//  This will be replaced with full implementation in Phase 3
//

import SwiftUI

/// Simple Task List View - Minimal implementation to make app run
/// PHASE 1.5: This is a placeholder. Real implementation comes in Phase 3.
struct TaskListView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                
                // Placeholder icon
                Image(systemName: "list.bullet.clipboard")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
                
                Text("Tasks")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Phase 1.5 - Placeholder View")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Task list will be implemented in Phase 3")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("SkillPulse")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Preview
#Preview {
    TaskListView()
}
