//
//  ActiveWorkoutPlanView.swift
//  AdaptFitness
//
//  View for displaying an active workout plan
//

import SwiftUI

struct ActiveWorkoutPlanView: View {
    let plan: WorkoutPlan
    @ObservedObject var viewModel: WorkoutPlanViewModel

    @State private var showExerciseDetail: ExercisePlan?
    @State private var showRetireConfirmation = false

    var currentDay: WorkoutDay? {
        let days = plan.workoutPlanData.days
        guard viewModel.selectedDay < days.count else { return nil }
        return days[viewModel.selectedDay]
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Text(plan.name)
                    .font(.title2)
                    .fontWeight(.bold)

                if let description = plan.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 10)

            // Day Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(plan.workoutPlanData.days.enumerated()), id: \.element.id) { index, day in
                        Button(action: {
                            viewModel.selectedDay = index
                        }) {
                            VStack(spacing: 4) {
                                Text("Day \(day.dayNumber)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Text(day.dayName)
                                    .font(.caption2)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(viewModel.selectedDay == index ? Color.blue : Color(.systemGray6))
                            .foregroundColor(viewModel.selectedDay == index ? .white : .primary)
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 10)

            // Exercise List
            if let day = currentDay {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(day.exercises) { exercise in
                            ExerciseCardView(exercise: exercise)
                                .onTapGesture {
                                    showExerciseDetail = exercise
                                }
                        }
                    }
                    .padding()

                    // Retire Button
                    Button(action: {
                        showRetireConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle")
                            Text("Retire Plan")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            } else {
                Spacer()
                Text("No exercises for this day")
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .sheet(item: $showExerciseDetail) { exercise in
            ExerciseDetailView(exercise: exercise)
        }
        .alert("Retire Workout Plan", isPresented: $showRetireConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Retire", role: .destructive) {
                Task {
                    await viewModel.retirePlan()
                }
            }
        } message: {
            Text("Are you sure you want to retire this workout plan? You can always generate a new one.")
        }
    }
}

struct ExerciseCardView: View {
    let exercise: ExercisePlan

    var displayName: String {
        exercise.exerciseDetails?.name ?? exercise.exerciseName
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Exercise Name
            Text(displayName)
                .font(.headline)
                .fontWeight(.semibold)

            // Sets and Reps
            HStack(spacing: 20) {
                HStack(spacing: 4) {
                    Image(systemName: "repeat")
                        .foregroundColor(.blue)
                    Text("\(exercise.sets) sets")
                        .font(.subheadline)
                }

                HStack(spacing: 4) {
                    Image(systemName: "number")
                        .foregroundColor(.blue)
                    Text(exercise.reps)
                        .font(.subheadline)
                }
            }

            // Exercise image preview if available
            if let details = exercise.exerciseDetails, !details.imageUrl.isEmpty {
                AsyncImage(url: URL(string: details.imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(height: 120)
                .cornerRadius(8)
                .clipped()
            }

            // Target muscles if available
            if let details = exercise.exerciseDetails, !details.targetMuscles.isEmpty {
                HStack {
                    Image(systemName: "figure.arms.open")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Text(details.targetMuscles.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Tap to view details hint
            HStack {
                Spacer()
                Text("Tap for details")
                    .font(.caption)
                    .foregroundColor(.blue)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    ActiveWorkoutPlanView(
        plan: WorkoutPlan(
            id: "1",
            userId: "user1",
            name: "Beginner Strength Plan",
            description: "A 4-week beginner strength training program",
            workoutPlanData: WorkoutPlanData(
                planName: "Beginner Strength Plan",
                planDescription: "Build foundational strength",
                days: [
                    WorkoutDay(
                        dayNumber: 1,
                        dayName: "Upper Body",
                        exercises: [
                            ExercisePlan(
                                exerciseName: "Push-ups",
                                sets: 3,
                                reps: "10-12",
                                exerciseDetails: nil,
                                dataSource: "ai_only",
                                matchConfidence: "none",
                                matchedExerciseName: nil,
                                searchStrategy: nil
                            )
                        ]
                    )
                ],
                enrichmentStats: nil
            ),
            isActive: true,
            isCompleted: false,
            completedAt: nil,
            createdAt: "2025-01-01",
            updatedAt: "2025-01-01"
        ),
        viewModel: WorkoutPlanViewModel()
    )
}
