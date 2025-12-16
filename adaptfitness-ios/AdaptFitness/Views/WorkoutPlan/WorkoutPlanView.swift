//
//  WorkoutPlanView.swift
//  AdaptFitness
//
//  Main view for AI-generated workout plans
//  Replaces BrowseWorkoutsView
//

import SwiftUI

struct WorkoutPlanView: View {
    @StateObject private var viewModel = WorkoutPlanViewModel()

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                // Loading state
                VStack {
                    Spacer()
                    ProgressView("Loading your workout plan...")
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                }
            } else if let plan = viewModel.activePlan {
                // Show active plan
                ActiveWorkoutPlanView(plan: plan, viewModel: viewModel)
            } else {
                // Show generate form
                GenerateWorkoutPlanFormView(viewModel: viewModel)
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchActivePlan()
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
    }
}

#Preview {
    WorkoutPlanView()
}
