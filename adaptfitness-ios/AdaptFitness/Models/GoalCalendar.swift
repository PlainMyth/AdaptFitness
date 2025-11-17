//
//  GoalCalendar.swift
//  AdaptFitness
//
//  Created by AI Assistant
//

import Foundation

struct GoalCalendar: Codable, Identifiable {
    let id: String
    let userId: String
    let weekStartDate: String
    let weekEndDate: String
    let goalType: GoalType
    let targetValue: Double
    let currentValue: Double
    let completionPercentage: Double
    let isCompleted: Bool
    let isActive: Bool
    let description: String?
    let workoutType: WorkoutType?
    let progressHistory: [ProgressEntry]?
    let createdAt: String
    let updatedAt: String
    
    var weekIdentifier: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let startDate = formatter.date(from: weekStartDate) {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: startDate)
            let weekOfYear = calendar.component(.weekOfYear, from: startDate)
            return "\(year)-W\(String(format: "%02d", weekOfYear))"
        }
        return "Unknown"
    }
    
    var status: String {
        if isCompleted { return "completed" }
        if completionPercentage >= 100 { return "achieved" }
        if completionPercentage >= 75 { return "on_track" }
        if completionPercentage >= 50 { return "moderate_progress" }
        if completionPercentage > 0 { return "started" }
        return "not_started"
    }
    
    var unit: String {
        switch goalType {
        case .workoutsCount: return "workouts"
        case .totalDuration: return "minutes"
        case .totalCalories: return "calories"
        case .totalSets: return "sets"
        case .totalReps: return "reps"
        case .totalWeight: return "kg"
        case .streakDays: return "days"
        }
    }
}

struct ProgressEntry: Codable {
    let date: String
    let value: Double
    let completionPercentage: Double
}

enum GoalType: String, Codable, CaseIterable {
    case workoutsCount = "workouts_count"
    case totalDuration = "total_duration"
    case totalCalories = "total_calories"
    case totalSets = "total_sets"
    case totalReps = "total_reps"
    case totalWeight = "total_weight"
    case streakDays = "streak_days"
    
    var displayName: String {
        switch self {
        case .workoutsCount: return "Workout Count"
        case .totalDuration: return "Total Duration"
        case .totalCalories: return "Total Calories"
        case .totalSets: return "Total Sets"
        case .totalReps: return "Total Reps"
        case .totalWeight: return "Total Weight"
        case .streakDays: return "Streak Days"
        }
    }
    
    var icon: String {
        switch self {
        case .workoutsCount: return "figure.strengthtraining.traditional"
        case .totalDuration: return "clock.fill"
        case .totalCalories: return "flame.fill"
        case .totalSets: return "number.circle.fill"
        case .totalReps: return "repeat.circle.fill"
        case .totalWeight: return "scalemass.fill"
        case .streakDays: return "calendar.badge.plus"
        }
    }
    
    var unit: String {
        switch self {
        case .workoutsCount: return "workouts"
        case .totalDuration: return "minutes"
        case .totalCalories: return "calories"
        case .totalSets: return "sets"
        case .totalReps: return "reps"
        case .totalWeight: return "kg"
        case .streakDays: return "days"
        }
    }
}

struct CreateGoalRequest: Codable {
    let weekStartDate: String
    let weekEndDate: String
    let goalType: GoalType
    let targetValue: Double
    let description: String?
    let workoutType: WorkoutType?
    let isActive: Bool
}

struct GoalStatistics: Codable {
    let totalGoals: Int
    let completedGoals: Int
    let activeGoals: Int
    let completionRate: Double
    let averageCompletion: Double?
    let goalTypeStats: [String: GoalTypeStats]
}

struct GoalTypeStats: Codable {
    let total: Int
    let completed: Int
    let averageCompletion: Double?
}

struct CalendarView: Codable {
    let month: Int
    let year: Int
    let weeklyGoals: [String: [GoalCalendar]]
    let totalWeeks: Int
    let totalGoals: Int
}
