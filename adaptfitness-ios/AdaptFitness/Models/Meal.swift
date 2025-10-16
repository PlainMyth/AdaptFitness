//
//  Meal.swift
//  AdaptFitness
//
//  Created by AI Assistant
//

import Foundation

struct Meal: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let mealTime: String
    let calories: Double
    let protein: Double?
    let carbs: Double?
    let fat: Double?
    let fiber: Double?
    let sugar: Double?
    let sodium: Double?
    let mealType: MealType?
    let userId: String
    let createdAt: String
    let updatedAt: String
}

enum MealType: String, Codable, CaseIterable {
    case breakfast = "breakfast"
    case lunch = "lunch"
    case dinner = "dinner"
    case snack = "snack"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .breakfast: return "Breakfast"
        case .lunch: return "Lunch"
        case .dinner: return "Dinner"
        case .snack: return "Snack"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.fill"
        case .snack: return "leaf.fill"
        case .other: return "fork.knife"
        }
    }
}

struct CreateMealRequest: Codable {
    let name: String
    let description: String?
    let mealTime: String
    let calories: Double
    let protein: Double?
    let carbs: Double?
    let fat: Double?
    let fiber: Double?
    let sugar: Double?
    let sodium: Double?
    let mealType: MealType?
}

struct MealStreak: Codable {
    let streak: Int
    let lastMealDate: String?
}
