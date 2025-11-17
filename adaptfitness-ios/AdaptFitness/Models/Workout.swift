//
//  Workout.swift
//  AdaptFitness
//
//  Created by AI Assistant
//

import Foundation
import Combine

struct Workout: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let startTime: String
    let endTime: String?
    let totalCaloriesBurned: Double
    let totalDuration: Double
    let totalSets: Double
    let totalReps: Double
    let totalWeight: Double
    let workoutType: WorkoutType?
    let isCompleted: Bool
    let userId: String
    let createdAt: String
    let updatedAt: String
    
    var duration: Double {
        if let endTime = endTime,
           let start = ISO8601DateFormatter().date(from: startTime),
           let end = ISO8601DateFormatter().date(from: endTime) {
            return end.timeIntervalSince(start) / 60 // Convert to minutes
        }
        return totalDuration
    }
    
    var status: String {
        if isCompleted { return "completed" }
        if endTime == nil { return "in_progress" }
        return "scheduled"
    }
}

enum WorkoutType: String, Codable, CaseIterable {
    case strength = "strength"
    case cardio = "cardio"
    case flexibility = "flexibility"
    case sports = "sports"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .strength: return "Strength Training"
        case .cardio: return "Cardio"
        case .flexibility: return "Flexibility"
        case .sports: return "Sports"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .strength: return "dumbbell.fill"
        case .cardio: return "heart.fill"
        case .flexibility: return "figure.flexibility"
        case .sports: return "sportscourt.fill"
        case .other: return "figure.mixed.cardio"
        }
    }
}

struct CreateWorkoutRequest: Codable {
    let name: String
    let description: String?
    let startTime: String
    let endTime: String?
    let totalCaloriesBurned: Double
    let totalDuration: Double
    let totalSets: Double
    let totalReps: Double
    let totalWeight: Double
    let workoutType: WorkoutType?
    let isCompleted: Bool
}

struct WorkoutStreak: Codable {
    let streak: Int
    let lastWorkoutDate: String?
}
