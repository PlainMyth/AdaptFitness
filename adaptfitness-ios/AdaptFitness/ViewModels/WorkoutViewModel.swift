//
//  WorkoutViewModel.swift
//  AdaptFitness
//
//  Created by OzzieC8 on 10/16/25.
//

import Foundation
import Combine

/// ViewModel for managing workout data and API interactions
@MainActor
class WorkoutViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var workouts: [WorkoutResponse] = []
    @Published var currentStreak: Int = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    // MARK: - Private Properties
    
    private let apiService = APIService.shared
    
    // MARK: - Public Methods
    
    /// Fetch all workouts for the current user
    func fetchWorkouts() async {
        isLoading = true
        errorMessage = nil
        
        guard let token = AuthManager.shared.authToken else {
            handleError(.unauthorized)
            return
        }
        
        do {
            let fetchedWorkouts = try await apiService.getWorkouts(token: token)
            // Convert Workout to WorkoutResponse for compatibility
            workouts = fetchedWorkouts.map { workout in
                let formatter = ISO8601DateFormatter()
                return WorkoutResponse(
                    id: workout.id,
                    name: workout.name,
                    description: workout.description,
                    startTime: formatter.date(from: workout.startTime) ?? Date(),
                    endTime: workout.endTime != nil ? formatter.date(from: workout.endTime!) : nil,
                    totalCaloriesBurned: workout.totalCaloriesBurned,
                    totalDuration: Int(workout.totalDuration),
                    notes: nil,
                    userId: workout.userId,
                    createdAt: formatter.date(from: workout.createdAt) ?? Date(),
                    updatedAt: formatter.date(from: workout.updatedAt) ?? Date()
                )
            }
            workouts = workouts.sorted { $0.startTime > $1.startTime }
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to fetch workouts"
            showError = true
        }
    }
    
    /// Fetch the current workout streak
    func fetchCurrentStreak() async {
        guard let token = AuthManager.shared.authToken else {
            currentStreak = 0
            return
        }
        
        do {
            let streak = try await apiService.getWorkoutStreak(token: token)
            currentStreak = streak.streak
        } catch {
            // Silently fail for streak - it's not critical
            currentStreak = 0
        }
    }
    
    /// Create a new workout
    func createWorkout(
        name: String,
        description: String? = nil,
        startTime: Date,
        endTime: Date? = nil,
        totalCaloriesBurned: Double = 0,
        totalDuration: Double = 0,
        totalSets: Double = 0,
        totalReps: Double = 0,
        totalWeight: Double = 0,
        workoutType: WorkoutType? = nil,
        isCompleted: Bool = true
    ) async throws {
        isLoading = true
        errorMessage = nil
        
        // Convert Date to ISO8601 String format
        let formatter = ISO8601DateFormatter()
        let startTimeString = formatter.string(from: startTime)
        let endTimeString = endTime != nil ? formatter.string(from: endTime!) : nil
        
        let request = CreateWorkoutRequest(
            name: name,
            description: description,
            startTime: startTimeString,
            endTime: endTimeString,
            totalCaloriesBurned: totalCaloriesBurned,
            totalDuration: totalDuration,
            totalSets: totalSets,
            totalReps: totalReps,
            totalWeight: totalWeight,
            workoutType: workoutType,
            isCompleted: isCompleted
        )
        
        guard let token = AuthManager.shared.authToken else {
            isLoading = false
            throw NetworkError.unauthorized
        }
        
        do {
            let createdWorkout = try await apiService.createWorkout(request, token: token)
            // Convert Workout to WorkoutResponse
            let formatter = ISO8601DateFormatter()
            let newWorkout = WorkoutResponse(
                id: createdWorkout.id,
                name: createdWorkout.name,
                description: createdWorkout.description,
                startTime: formatter.date(from: createdWorkout.startTime) ?? Date(),
                endTime: createdWorkout.endTime != nil ? formatter.date(from: createdWorkout.endTime!) : nil,
                totalCaloriesBurned: createdWorkout.totalCaloriesBurned,
                totalDuration: Int(createdWorkout.totalDuration),
                notes: nil,
                userId: createdWorkout.userId,
                createdAt: formatter.date(from: createdWorkout.createdAt) ?? Date(),
                updatedAt: formatter.date(from: createdWorkout.updatedAt) ?? Date()
            )
            workouts.insert(newWorkout, at: 0)
            isLoading = false
            
            // Refresh streak after creating workout
            await fetchCurrentStreak()
        } catch {
            isLoading = false
            throw NetworkError.invalidResponse
        }
    }
    
    /// Delete a workout
    func deleteWorkout(id: String) async throws {
        guard let token = AuthManager.shared.authToken else {
            throw NetworkError.unauthorized
        }
        
        do {
            try await apiService.deleteWorkout(id: id, token: token)
            workouts.removeAll { $0.id == id }
            
            // Refresh streak after deleting workout
            await fetchCurrentStreak()
        } catch {
            throw NetworkError.invalidResponse
        }
    }
    
    /// Update an existing workout
    func updateWorkout(
        id: String,
        name: String? = nil,
        description: String? = nil,
        totalCaloriesBurned: Double? = nil,
        totalDuration: Int? = nil,
        notes: String? = nil
    ) async throws {
        guard let token = AuthManager.shared.authToken else {
            throw NetworkError.unauthorized
        }
        
        // For update, we need to create a CreateWorkoutRequest with the updated values
        // Since we don't have the original workout here, we'll use the provided values or defaults
        let formatter = ISO8601DateFormatter()
        let now = formatter.string(from: Date())
        
        let request = CreateWorkoutRequest(
            name: name ?? "",
            description: description,
            startTime: now,
            endTime: nil,
            totalCaloriesBurned: totalCaloriesBurned ?? 0,
            totalDuration: totalDuration != nil ? Double(totalDuration!) : 0,
            totalSets: 0,
            totalReps: 0,
            totalWeight: 0,
            workoutType: nil,
            isCompleted: true
        )
        
        do {
            let updated = try await apiService.updateWorkout(id: id, workout: request, token: token)
            // Convert Workout to WorkoutResponse
            let updatedResponse = WorkoutResponse(
                id: updated.id,
                name: updated.name,
                description: updated.description,
                startTime: formatter.date(from: updated.startTime) ?? Date(),
                endTime: updated.endTime != nil ? formatter.date(from: updated.endTime!) : nil,
                totalCaloriesBurned: updated.totalCaloriesBurned,
                totalDuration: Int(updated.totalDuration),
                notes: nil,
                userId: updated.userId,
                createdAt: formatter.date(from: updated.createdAt) ?? Date(),
                updatedAt: formatter.date(from: updated.updatedAt) ?? Date()
            )
            
            if let index = workouts.firstIndex(where: { $0.id == id }) {
                workouts[index] = updatedResponse
            }
        } catch {
            throw NetworkError.invalidResponse
        }
    }
    
    /// Refresh all data (workouts and streak)
    func refresh() async {
        await fetchWorkouts()
        await fetchCurrentStreak()
    }
    
    // MARK: - Private Methods
    
    private func handleError(_ error: NetworkError) {
        isLoading = false
        errorMessage = error.localizedDescription
        showError = true
    }
}

// MARK: - API Models

struct WorkoutResponse: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let startTime: Date
    let endTime: Date?
    let totalCaloriesBurned: Double?
    let totalDuration: Int?
    let notes: String?
    let userId: String
    let createdAt: Date
    let updatedAt: Date
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: startTime)
    }
    
    var caloriesDisplay: String {
        if let calories = totalCaloriesBurned {
            return "\(Int(calories)) kcal"
        }
        return "N/A"
    }
    
    var durationDisplay: String {
        if let duration = totalDuration {
            let hours = duration / 60
            let minutes = duration % 60
            if hours > 0 {
                return "\(hours)h \(minutes)m"
            }
            return "\(minutes)m"
        }
        return "N/A"
    }
}

struct UpdateWorkoutRequest: Encodable {
    let name: String?
    let description: String?
    let totalCaloriesBurned: Double?
    let totalDuration: Int?
    let notes: String?
}

struct StreakResponse: Decodable {
    let streak: Int
    let lastWorkoutDate: String?
}

