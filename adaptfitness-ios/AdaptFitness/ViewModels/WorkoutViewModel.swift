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
    
    // Use APIService.shared (from Core/Network/APIService.swift)
    // This has the .request() method with HTTPMethod enum support
    // Note: There are two APIService classes - this uses the one with .request() method
    private let apiService = APIService.shared
    
    // MARK: - Public Methods
    
    /// Fetch all workouts for the current user
    func fetchWorkouts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response: [WorkoutResponse] = try await apiService.request(
                endpoint: "/workouts",
                method: .get,
                requiresAuth: true
            )
            workouts = response.sorted { $0.startTime > $1.startTime }
            isLoading = false
        } catch let error as NetworkError {
            handleError(error)
        } catch {
            handleError(.invalidResponse)
        }
    }
    
    /// Fetch the current workout streak
    func fetchCurrentStreak() async {
        do {
            let response: StreakResponse = try await apiService.request(
                endpoint: "/workouts/streak/current",
                method: .get,
                requiresAuth: true
            )
            currentStreak = response.streak
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
        totalCaloriesBurned: Double? = nil,
        totalDuration: Int? = nil,
        notes: String? = nil
    ) async throws {
        isLoading = true
        errorMessage = nil
        
        // Convert Date to ISO8601 String format for backend
        let formatter = ISO8601DateFormatter()
        let startTimeString = formatter.string(from: startTime)
        let endTimeString = endTime != nil ? formatter.string(from: endTime!) : nil
        
        // Create request matching backend CreateWorkoutDto structure
        struct BackendCreateWorkoutRequest: Encodable {
            let name: String
            let description: String?
            let startTime: String
            let endTime: String?
            let totalCaloriesBurned: Double?
            let totalDuration: Int?
            let notes: String?
        }
        
        let request = BackendCreateWorkoutRequest(
            name: name,
            description: description,
            startTime: startTimeString,
            endTime: endTimeString,
            totalCaloriesBurned: totalCaloriesBurned,
            totalDuration: totalDuration,
            notes: notes
        )
        
        do {
            // Use the new APIService.request() method
            let newWorkout: WorkoutResponse = try await apiService.request(
                endpoint: "/workouts",
                method: .post,
                body: request,
                requiresAuth: true
            )
            workouts.insert(newWorkout, at: 0)
            isLoading = false
            
            // Refresh streak after creating workout
            await fetchCurrentStreak()
        } catch let error as NetworkError {
            isLoading = false
            throw error
        } catch {
            isLoading = false
            throw NetworkError.invalidResponse
        }
    }
    
    /// Delete a workout
    func deleteWorkout(id: String) async throws {
        do {
            struct EmptyResponse: Decodable {}
            let _: EmptyResponse = try await apiService.request(
                endpoint: "/workouts/\(id)",
                method: .delete,
                requiresAuth: true
            )
            workouts.removeAll { $0.id == id }
            
            // Refresh streak after deleting workout
            await fetchCurrentStreak()
        } catch let error as NetworkError {
            throw error
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
        let request = UpdateWorkoutRequest(
            name: name,
            description: description,
            totalCaloriesBurned: totalCaloriesBurned,
            totalDuration: totalDuration,
            notes: notes
        )
        
        do {
            let updated: WorkoutResponse = try await apiService.request(
                endpoint: "/workouts/\(id)",
                method: .put,
                body: request,
                requiresAuth: true
            )
            
            if let index = workouts.firstIndex(where: { $0.id == id }) {
                workouts[index] = updated
            }
        } catch let error as NetworkError {
            throw error
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

// Note: CreateWorkoutRequest is defined in Models/Workout.swift
// Using that definition to avoid duplication

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

