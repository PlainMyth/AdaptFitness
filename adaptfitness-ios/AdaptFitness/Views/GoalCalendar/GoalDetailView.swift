//
//  GoalDetailView.swift
//  AdaptFitness
//
//  Created by AI Assistant
//

import SwiftUI

struct GoalDetailView: View {
    let goal: GoalCalendar
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: goal.goalType.icon)
                                .font(.title)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading) {
                                Text(goal.description ?? goal.goalType.displayName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                if let workoutType = goal.workoutType {
                                    Text(workoutType.displayName)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                        }
                        
                        Text("Week: \(goal.weekIdentifier)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Progress Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Progress")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("\(Int(goal.completionPercentage))%")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(progressColor)
                                
                                Spacer()
                                
                                Text(goal.status.capitalized)
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(progressColor.opacity(0.2))
                                    .foregroundColor(progressColor)
                                    .cornerRadius(8)
                            }
                            
                            ProgressView(value: goal.completionPercentage / 100)
                                .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                            
                            Text("\(Int(goal.currentValue)) / \(Int(goal.targetValue)) \(goal.unit)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Goal Details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Goal Details")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        DetailRow(title: "Goal Type", value: goal.goalType.displayName)
                        DetailRow(title: "Target", value: "\(Int(goal.targetValue)) \(goal.unit)")
                        DetailRow(title: "Current", value: "\(Int(goal.currentValue)) \(goal.unit)")
                        DetailRow(title: "Status", value: goal.isCompleted ? "Completed" : "In Progress")
                        DetailRow(title: "Active", value: goal.isActive ? "Yes" : "No")
                        DetailRow(title: "Week Start", value: formatDate(goal.weekStartDate))
                        DetailRow(title: "Week End", value: formatDate(goal.weekEndDate))
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Progress History
                    if let progressHistory = goal.progressHistory, !progressHistory.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Progress History")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            ForEach(progressHistory.suffix(7), id: \.date) { entry in
                                HStack {
                                    Text(formatDate(entry.date))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(entry.value)) \(goal.unit)")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    
                                    Text("(\(Int(entry.completionPercentage))%)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Goal Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var progressColor: Color {
        switch goal.status {
        case "completed", "achieved": return .green
        case "on_track": return .blue
        case "moderate_progress": return .orange
        case "started": return .yellow
        default: return .gray
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .none
        
        return displayFormatter.string(from: date)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    let sampleGoal = GoalCalendar(
        id: "1",
        userId: "user1",
        weekStartDate: "2025-10-13T00:00:00Z",
        weekEndDate: "2025-10-19T00:00:00Z",
        goalType: .workoutsCount,
        targetValue: 5,
        currentValue: 3,
        completionPercentage: 60,
        isCompleted: false,
        isActive: true,
        description: "Complete 5 workouts this week",
        workoutType: nil,
        progressHistory: [
            ProgressEntry(date: "2025-10-15", value: 3, completionPercentage: 60)
        ],
        createdAt: "2025-10-13T00:00:00Z",
        updatedAt: "2025-10-15T00:00:00Z"
    )
    
    GoalDetailView(goal: sampleGoal)
}
