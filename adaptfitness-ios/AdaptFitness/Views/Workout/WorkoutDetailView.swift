//
//  WorkoutDetailView.swift
//  AdaptFitness
//
//  Created by AI Assistant
//

import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: workout.workoutType?.icon ?? "figure.mixed.cardio")
                                .font(.title)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading) {
                                Text(workout.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                if let workoutType = workout.workoutType {
                                    Text(workoutType.displayName)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                        }
                        
                        if let description = workout.description, !description.isEmpty {
                            Text(description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Stats Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        StatCard(
                            title: "Duration",
                            value: "\(Int(workout.totalDuration))",
                            unit: "minutes",
                            icon: "clock.fill",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Calories",
                            value: "\(Int(workout.totalCaloriesBurned))",
                            unit: "burned",
                            icon: "flame.fill",
                            color: .orange
                        )
                        
                        StatCard(
                            title: "Sets",
                            value: "\(Int(workout.totalSets))",
                            unit: "completed",
                            icon: "number.circle.fill",
                            color: .green
                        )
                        
                        StatCard(
                            title: "Reps",
                            value: "\(Int(workout.totalReps))",
                            unit: "total",
                            icon: "repeat.circle.fill",
                            color: .purple
                        )
                        
                        StatCard(
                            title: "Weight",
                            value: "\(Int(workout.totalWeight))",
                            unit: "kg lifted",
                            icon: "scalemass.fill",
                            color: .red
                        )
                        
                        StatCard(
                            title: "Status",
                            value: workout.status.capitalized,
                            unit: "",
                            icon: statusIcon,
                            color: statusColor
                        )
                    }
                    
                    // Timing Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Timing")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Start Time")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(formatDate(workout.startTime))
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                            
                            Spacer()
                            
                            if let endTime = workout.endTime {
                                VStack(alignment: .trailing) {
                                    Text("End Time")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(formatDate(endTime))
                                        .font(.body)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Workout Details")
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
    
    private var statusIcon: String {
        switch workout.status {
        case "completed": return "checkmark.circle.fill"
        case "in_progress": return "clock.fill"
        default: return "calendar.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch workout.status {
        case "completed": return .green
        case "in_progress": return .orange
        default: return .gray
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        
        return displayFormatter.string(from: date)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    let sampleWorkout = Workout(
        id: "1",
        name: "Upper Body Strength",
        description: "Chest, shoulders, and arms workout",
        startTime: "2025-10-15T10:00:00Z",
        endTime: "2025-10-15T11:00:00Z",
        totalCaloriesBurned: 400,
        totalDuration: 60,
        totalSets: 15,
        totalReps: 120,
        totalWeight: 2500,
        workoutType: .strength,
        isCompleted: true,
        userId: "user1",
        createdAt: "2025-10-15T10:00:00Z",
        updatedAt: "2025-10-15T11:00:00Z"
    )
    
    WorkoutDetailView(workout: sampleWorkout)
}
