//
//  BrowseView.swift
//  AdaptFitness
//
//  Created by csuftitan on 9/17/25.
//

import SwiftUI

// BrowseWorkout struct for displaying workout templates in browse view
struct BrowseWorkout: Identifiable {
    let id = UUID()
    let name: String
    let intensity: String
    let calories: String
    let systemImage: String
}

struct BrowseWorkoutsView: View {
    @State private var workoutToShow: BrowseWorkout?
    
    let workouts: [BrowseWorkout] = [
        BrowseWorkout(name: "Add Custom Workout", intensity: "", calories: "", systemImage: "plus.circle"),
        BrowseWorkout(name: "Running", intensity: "High", calories: "352 per 30 min", systemImage: "figure.run"),
        BrowseWorkout(name: "Walking", intensity: "Low", calories: "150 per 30 min", systemImage: "figure.walk"),
        BrowseWorkout(name: "Swimming", intensity: "High", calories: "215 per 30 min", systemImage: "drop.fill"),
        BrowseWorkout(name: "Cycling", intensity: "Low-High", calories: "225 per 30 min", systemImage: "bicycle"),
        BrowseWorkout(name: "Hiking", intensity: "Low-Moderate", calories: "180 per 30 min", systemImage: "figure.hiking"),
        BrowseWorkout(name: "Yoga", intensity: "Low-High", calories: "173 per 30 min", systemImage: "figure.cooldown"),
        BrowseWorkout(name: "Boxing", intensity: "High", calories: "400 per 30 min", systemImage: "figure.boxing")
    ]
    
    var body: some View {
        VStack {
            // Header
            Text("Browse Workouts")
                .font(.largeTitle)
                .bold()
                .padding(.top, 20)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(workouts) { workout in
                        WorkoutTile(workout: workout) {
                            print("BrowseWorkoutsView - Tapped workout: \(workout.name)")
                            workoutToShow = workout
                            print("BrowseWorkoutsView - Set workoutToShow to: \(workout.name)")
                        }
                    }
                }
                .padding()
            }
            
            Spacer()
        }
        .sheet(item: $workoutToShow) { workout in
            // Convert BrowseWorkout to Workout for WorkoutDetailView
            let convertedWorkout = Workout(
                id: workout.id.uuidString,
                name: workout.name,
                description: nil,
                startTime: ISO8601DateFormatter().string(from: Date()),
                endTime: nil,
                totalCaloriesBurned: 0,
                totalDuration: 0,
                totalSets: 0,
                totalReps: 0,
                totalWeight: 0,
                workoutType: .other,
                isCompleted: false,
                userId: "",
                createdAt: ISO8601DateFormatter().string(from: Date()),
                updatedAt: ISO8601DateFormatter().string(from: Date())
            )
            WorkoutDetailView(workout: convertedWorkout)
        }
    }
}

struct WorkoutTile: View {
    let workout: BrowseWorkout
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            print("WorkoutTile button tapped for: \(workout.name)")
            onTap()
        }) {
            VStack(spacing: 10) {
                Image(systemName: workout.systemImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                    .padding()
                
                Text(workout.name)
                    .font(.headline)
                
                if !workout.intensity.isEmpty {
                    Text("Intensity: \(workout.intensity)")
                        .font(.subheadline)
                }
                if !workout.calories.isEmpty {
                    Text("Est Cal: \(workout.calories)")
                        .font(.subheadline)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 150)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


#Preview {
    BrowseWorkoutsView()
}
