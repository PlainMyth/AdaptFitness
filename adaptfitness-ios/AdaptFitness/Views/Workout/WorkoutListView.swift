//
//  WorkoutListView.swift
//  AdaptFitness
//
//  Created by AI Assistant
//

import SwiftUI

struct WorkoutListView: View {
    @StateObject private var viewModel = WorkoutViewModel()
    @State private var showingAddWorkout = false
    @State private var selectedWorkout: WorkoutResponse?
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading workouts...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.workouts.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Workouts Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Start your fitness journey by adding your first workout!")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button("Add Workout") {
                            showingAddWorkout = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.workouts) { workout in
                            WorkoutRowView(workout: workout)
                                .onTapGesture {
                                    selectedWorkout = workout
                                }
                        }
                        .onDelete(perform: deleteWorkouts)
                    }
                }
            }
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddWorkout = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddWorkout) {
                AddWorkoutView { newWorkout in
                    Task {
                        await viewModel.fetchWorkouts()
                    }
                }
            }
            .sheet(item: $selectedWorkout) { workout in
                WorkoutDetailView(workout: workout)
            }
        }
        .task {
            await viewModel.fetchWorkouts()
            await viewModel.fetchCurrentStreak()
        }
    }
    
    private func deleteWorkouts(offsets: IndexSet) {
        Task {
            for index in offsets {
                let workout = viewModel.workouts[index]
                try? await viewModel.deleteWorkout(id: workout.id)
            }
            await viewModel.fetchWorkouts()
        }
    }
}

struct WorkoutRowView: View {
    let workout: WorkoutResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "figure.mixed.cardio")
                    .foregroundColor(.blue)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(workout.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if let description = workout.description, !description.isEmpty {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    if let duration = workout.totalDuration {
                        Text("\(duration)m")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    
                    if let calories = workout.totalCaloriesBurned {
                        Text("\(Int(calories)) cal")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            HStack {
                Spacer()
                
                Text(workout.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    WorkoutListView()
}
