//
//  GenerateWorkoutPlanFormView.swift
//  AdaptFitness
//
//  Form for generating a new AI workout plan
//

import SwiftUI

struct GenerateWorkoutPlanFormView: View {
    @ObservedObject var viewModel: WorkoutPlanViewModel

    @State private var userGoal: String = ""
    @State private var experienceLevel: String = "beginner"
    @State private var daysPerWeek: Int = 3

    let experienceLevels = ["beginner", "intermediate", "advanced"]

    var isFormValid: Bool {
        !userGoal.trimmingCharacters(in: .whitespaces).isEmpty && daysPerWeek >= 3 && daysPerWeek <= 7
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "figure.run")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("Generate Your Workout Plan")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Get a personalized AI-powered workout plan")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)

                // Form
                VStack(spacing: 20) {
                    // User Goal
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Goal")
                            .font(.headline)

                        TextEditor(text: $userGoal)
                            .frame(height: 100)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )

                        Text("Example: Build muscle, lose weight, improve endurance")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Experience Level
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Experience Level")
                            .font(.headline)

                        Picker("Experience Level", selection: $experienceLevel) {
                            ForEach(experienceLevels, id: \.self) { level in
                                Text(level.capitalized).tag(level)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }

                    // Days Per Week
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Days Per Week")
                            .font(.headline)

                        HStack {
                            Stepper(value: $daysPerWeek, in: 3...7) {
                                Text("\(daysPerWeek) days")
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                        Text("Choose between 3-7 training days per week")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)

                // Generate Button
                Button(action: {
                    Task {
                        await viewModel.generateAndSavePlan(
                            userGoal: userGoal,
                            experienceLevel: experienceLevel,
                            daysPerWeek: daysPerWeek
                        )
                    }
                }) {
                    HStack {
                        if viewModel.isGenerating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "wand.and.stars")
                        }
                        Text(viewModel.isGenerating ? "Generating..." : "Generate Plan")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid && !viewModel.isGenerating ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(!isFormValid || viewModel.isGenerating)
                .padding(.horizontal)
                .padding(.top, 10)

                Spacer()
            }
        }
    }
}

#Preview {
    GenerateWorkoutPlanFormView(viewModel: WorkoutPlanViewModel())
}
