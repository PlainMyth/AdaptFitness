//
//  GoalCalendar.swift
//  AdaptFitness
//
//  Created by AI Assistant
//

import Foundation

struct GoalCalendar: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let weekStartDate: String
    let weekEndDate: String
    let goalType: String

    let targetValue: String
    let currentValue: String
    let completionPercentage: String

    let isCompleted: Bool
    let isActive: Bool
    let description: String?
    let workoutType: String?
    let progressHistory: [ProgressEntry]?
    let createdAt: String
    let updatedAt: String
}

extension GoalCalendar {
    var goalTypeEnum: GoalType? {
        GoalType(rawValue: goalType)
    }
}

extension GoalCalendar {
    var targetValueDouble: Double {
        Double(targetValue) ?? 0
    }

    var currentValueDouble: Double {
        Double(currentValue) ?? 0
    }

    var completionPercentageDouble: Double {
        Double(completionPercentage) ?? 0
    }
}

extension GoalCalendar {
    var completionFraction: Double {
        (Double(completionPercentage) ?? 0.0) / 100.0
    }
}


extension GoalCalendar {
    var weekIdentifier: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        guard let startDate = formatter.date(from: weekStartDate) else {
            return "Unknown"
        }

        let calendar = Calendar.current
        let year = calendar.component(.yearForWeekOfYear, from: startDate)
        let week = calendar.component(.weekOfYear, from: startDate)

        return "\(year)-W\(String(format: "%02d", week))"
    }
}

extension GoalCalendar {
    var status: String {
        let percent = completionPercentageDouble

        if isCompleted { return "completed" }
        if percent >= 100 { return "achieved" }
        if percent >= 75 { return "on_track" }
        if percent >= 50 { return "moderate_progress" }
        if percent > 0 { return "started" }
        return "not_started"
    }
}

extension GoalCalendar {
    var unit: String {
        switch goalType {
        case GoalType.workoutsCount.rawValue: return "workouts"
        case GoalType.totalDuration.rawValue: return "minutes"
        case GoalType.totalCalories.rawValue: return "calories"
        case GoalType.totalSets.rawValue: return "sets"
        case GoalType.totalReps.rawValue: return "reps"
        case GoalType.totalWeight.rawValue: return "kg"
        case GoalType.streakDays.rawValue: return "days"
        default: return ""
        }
    }
}

extension GoalCalendar {
    var workoutTypeEnum: WorkoutType? {
        guard let workoutType else { return nil }
        return WorkoutType(rawValue: workoutType)
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

// GoalStatistics struct for API responses
// Note: Not marked with @MainActor to allow decoding in non-isolated contexts
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
