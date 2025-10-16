//
//  WorkoutViewModel.swift
//  AdaptFitness
//
//  Created by AI Assistant
//

import Foundation
import SwiftUI

@MainActor
class WorkoutViewModel: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let authManager = AuthManager()
    private let apiService = APIService.shared
    
    func loadWorkouts() {
        guard let token = authManager.authToken else {
            error = "Not authenticated"
            return
        }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                let fetchedWorkouts = try await apiService.getWorkouts(token: token)
                workouts = fetchedWorkouts
                isLoading = false
            } catch {
                self.error = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    func addWorkout(_ workout: Workout) {
        workouts.insert(workout, at: 0)
    }
    
    func deleteWorkouts(at offsets: IndexSet) {
        // Note: In a real app, you'd also call the API to delete from the server
        workouts.remove(atOffsets: offsets)
    }
    
    func refreshWorkouts() {
        loadWorkouts()
    }
    
    var totalWorkoutsThisWeek: Int {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        return workouts.filter { workout in
            let formatter = ISO8601DateFormatter()
            guard let workoutDate = formatter.date(from: workout.startTime) else { return false }
            return workoutDate >= startOfWeek
        }.count
    }
    
    var totalCaloriesThisWeek: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        return workouts.filter { workout in
            let formatter = ISO8601DateFormatter()
            guard let workoutDate = formatter.date(from: workout.startTime) else { return false }
            return workoutDate >= startOfWeek
        }.reduce(0) { $0 + $1.totalCaloriesBurned }
    }
    
    var totalDurationThisWeek: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        return workouts.filter { workout in
            let formatter = ISO8601DateFormatter()
            guard let workoutDate = formatter.date(from: workout.startTime) else { return false }
            return workoutDate >= startOfWeek
        }.reduce(0) { $0 + $1.totalDuration }
    }
}
