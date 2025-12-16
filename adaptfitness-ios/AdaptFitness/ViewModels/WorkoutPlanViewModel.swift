//
//  WorkoutPlanViewModel.swift
//  AdaptFitness
//
//  ViewModel for managing AI-generated workout plans
//

import Foundation
import Combine

@MainActor
class WorkoutPlanViewModel: ObservableObject {
    @Published var activePlan: WorkoutPlan?
    @Published var isLoading = false
    @Published var isGenerating = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var selectedDay: Int = 0

    private let apiService = APIService.shared

    // Fetch active plan on view load
    func fetchActivePlan() async {
        isLoading = true
        errorMessage = nil

        guard let token = AuthManager.shared.authToken else {
            handleError("Not authenticated. Please log in.")
            return
        }

        do {
            activePlan = try await apiService.getActiveWorkoutPlan(token: token)
            isLoading = false
        } catch {
            isLoading = false
            // Don't show error if no active plan exists (404 is expected)
            if let apiError = error as? APIError,
               case .httpError(404, _) = apiError {
                activePlan = nil
            } else {
                errorMessage = "Failed to load workout plan: \(error.localizedDescription)"
                showError = true
            }
        }
    }

    // Generate and save new plan
    func generateAndSavePlan(
        userGoal: String,
        experienceLevel: String,
        daysPerWeek: Int
    ) async {
        isGenerating = true
        errorMessage = nil

        guard let token = AuthManager.shared.authToken else {
            isGenerating = false
            handleError("Not authenticated. Please log in.")
            return
        }

        let request = GenerateWorkoutPlanRequest(
            userGoal: userGoal,
            experienceLevel: experienceLevel,
            daysPerWeek: daysPerWeek
        )

        do {
            let plan = try await apiService.generateAndSaveWorkoutPlan(request, token: token)
            activePlan = plan
            selectedDay = 0  // Reset to first day
            isGenerating = false
        } catch {
            isGenerating = false
            errorMessage = "Failed to generate workout plan: \(error.localizedDescription)"
            showError = true
        }
    }

    // Retire current plan
    func retirePlan() async {
        guard let plan = activePlan,
              let token = AuthManager.shared.authToken else {
            return
        }

        isLoading = true

        do {
            _ = try await apiService.retireWorkoutPlan(id: plan.id, token: token)
            activePlan = nil
            selectedDay = 0
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to retire workout plan: \(error.localizedDescription)"
            showError = true
        }
    }

    private func handleError(_ message: String) {
        isLoading = false
        isGenerating = false
        errorMessage = message
        showError = true
    }
}
