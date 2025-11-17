//
//  WorkoutDetailView.swift
//  AdaptFitness
//
//  Created by AI Assistant
//

import SwiftUI

struct WorkoutDetailView: View {
    let workout: WorkoutResponse
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "figure.mixed.cardio")
                                .font(.title)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading) {
                                Text(workout.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
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
                        if let duration = workout.totalDuration {
                            StatCard(
                                title: "Duration",
                                value: "\(duration)",
                                unit: "minutes",
                                icon: "clock.fill",
                                color: .blue
                            )
                        }
                        
                        if let calories = workout.totalCaloriesBurned {
                            StatCard(
                                title: "Calories",
                                value: "\(Int(calories))",
                                unit: "burned",
                                icon: "flame.fill",
                                color: .orange
                            )
                        }
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
    
    private func formatDate(_ date: Date) -> String {
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
    let sampleWorkout = WorkoutResponse(
        id: "1",
        name: "Upper Body Strength",
        description: "Chest, shoulders, and arms workout",
        startTime: Date(),
        endTime: Date().addingTimeInterval(3600),
        totalCaloriesBurned: 400,
        totalDuration: 60,
        notes: nil,
        userId: "user1",
        createdAt: Date(),
        updatedAt: Date()
    )
    
    WorkoutDetailView(workout: sampleWorkout)
}
