//
//  MealModels.swift
//  AdaptFitness
//
//  Meal-related request and response models
//

import Foundation

struct CreateMealRequest: Codable {
    let name: String
    let description: String?
    let mealTime: String
    let totalCalories: Double
    let mealType: String?
    let totalProtein: Double?
    let totalCarbs: Double?
    let totalFat: Double?
    let totalFiber: Double?
    let totalSugar: Double?
    let totalSodium: Double?
    let servingSize: Double?
    let servingUnit: String?
}

struct MealStreak: Codable {
    let streak: Int
    let lastMealDate: String?
}

