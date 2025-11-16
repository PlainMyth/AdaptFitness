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
    @State private var selectedWorkout: Workout?
    
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
                    viewModel.addWorkout(newWorkout)
                }
            }
            .sheet(item: $selectedWorkout) { workout in
                WorkoutDetailView(workout: workout)
            }
        }
        .onAppear {
            viewModel.loadWorkouts()
        }
    }
    
    private func deleteWorkouts(offsets: IndexSet) {
        withAnimation {
            viewModel.deleteWorkouts(at: offsets)
        }
    }
}

struct WorkoutRowView: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: workout.workoutType?.icon ?? "figure.mixed.cardio")
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
                    Text("\(Int(workout.totalDuration))m")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text("\(Int(workout.totalCaloriesBurned)) cal")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                if let workoutType = workout.workoutType {
                    Text(workoutType.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Text(workout.status.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(statusColor.opacity(0.1))
                    .foregroundColor(statusColor)
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var statusColor: Color {
        switch workout.status {
        case "completed": return .green
        case "in_progress": return .orange
        default: return .gray
        }
    }
}

#Preview {
    WorkoutListView()
}
