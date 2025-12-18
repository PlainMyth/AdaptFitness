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

    let targetValue: Double
    let currentValue: Double
    let completionPercentage: Double

    let isCompleted: Bool
    let isActive: Bool
    let description: String?
    let workoutType: String?
    let progressHistory: [ProgressEntry]?
    let createdAt: String
    let updatedAt: String
    
    // Custom decoding to handle both String and Number types from backend
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        userId = try container.decode(UUID.self, forKey: .userId)
        weekStartDate = try container.decode(String.self, forKey: .weekStartDate)
        weekEndDate = try container.decode(String.self, forKey: .weekEndDate)
        goalType = try container.decode(String.self, forKey: .goalType)
        
        // Handle targetValue - can come as String or Double from backend
        if let doubleValue = try? container.decode(Double.self, forKey: .targetValue) {
            targetValue = doubleValue
        } else if let stringValue = try? container.decode(String.self, forKey: .targetValue),
                  let parsed = Double(stringValue) {
            targetValue = parsed
        } else {
            targetValue = 0
        }
        
        // Handle currentValue - can come as String or Double from backend
        if let doubleValue = try? container.decode(Double.self, forKey: .currentValue) {
            currentValue = doubleValue
        } else if let stringValue = try? container.decode(String.self, forKey: .currentValue),
                  let parsed = Double(stringValue) {
            currentValue = parsed
        } else {
            currentValue = 0
        }
        
        // Handle completionPercentage - can come as String or Double from backend
        if let doubleValue = try? container.decode(Double.self, forKey: .completionPercentage) {
            completionPercentage = doubleValue
        } else if let stringValue = try? container.decode(String.self, forKey: .completionPercentage),
                  let parsed = Double(stringValue) {
            completionPercentage = parsed
        } else {
            completionPercentage = 0
        }
        
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        workoutType = try container.decodeIfPresent(String.self, forKey: .workoutType)
        progressHistory = try container.decodeIfPresent([ProgressEntry].self, forKey: .progressHistory)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, userId, weekStartDate, weekEndDate, goalType
        case targetValue, currentValue, completionPercentage
        case isCompleted, isActive, description, workoutType
        case progressHistory, createdAt, updatedAt
    }
}

extension GoalCalendar {
    var goalTypeEnum: GoalType? {
        GoalType(rawValue: goalType)
    }
}

extension GoalCalendar {
    // These are now direct properties since we decode as Double
    var targetValueDouble: Double {
        targetValue
    }

    var currentValueDouble: Double {
        currentValue
    }

    var completionPercentageDouble: Double {
        completionPercentage
    }
}

extension GoalCalendar {
    var completionFraction: Double {
        completionPercentage / 100.0
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
