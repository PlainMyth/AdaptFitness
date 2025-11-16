//
//  Meal.swift
//  AdaptFitness
//
//  Created by csuftitan on 10/13/25.
//
import SwiftUI

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

struct Meal: Codable, Identifiable {
    var id: String
    var userId: String
    var date: Date
    var type: String
    var mealType: MealType? {
        MealType(rawValue: type)
    }
    var foods: [FoodEntry]
    
    // Backend API fields
    var name: String?
    var description: String?
    var mealTime: String?
    var totalCalories: Double?
    var totalProtein: Double?
    var totalCarbs: Double?
    var totalFat: Double?
    var totalFiber: Double?
    var totalSugar: Double?
    var totalSodium: Double?
}

// Request struct for creating meals via API
struct CreateMealRequest: Codable {
    let name: String
    let description: String?
    let mealTime: String
    let totalCalories: Double
    let totalProtein: Double?
    let totalCarbs: Double?
    let totalFat: Double?
    let totalFiber: Double?
    let totalSugar: Double?
    let totalSodium: Double?
    let mealType: MealType?
    let servingSize: Double?
    let servingUnit: String?
}

extension Meal {
    var dayLabel: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    static let exampleMeals: [Meal] = [
        Meal(
            id: UUID().uuidString,
            userId: "user123",
            date: Date(),
            type: "breakfast",
            foods: [FoodEntry.exampleFoodEntries[0], FoodEntry.exampleFoodEntries[2]]
        ),
        Meal(
            id: UUID().uuidString,
            userId: "user123",
            date: Date().addingTimeInterval(-86400),
            type: "breakfast",
            foods: [FoodEntry.exampleFoodEntries[1], FoodEntry.exampleFoodEntries[3], FoodEntry.exampleFoodEntries[4]]
        )
    ]
}

extension Array where Element == Meal {
    func groupedByDayDescending() -> [(day: Date, meals: [Meal])] {
        let grouped = Dictionary(grouping: self) { Calendar.current.startOfDay(for: $0.date) }
        return grouped
            .map { (day: $0.key, meals: $0.value) }
            .sorted { $0.day > $1.day } // newest first
    }
}

//extension Meal {
//    static let example = Meal(
//        id: UUID().uuidString,
//        userId: "user123",
//        startDate: Date(),
//        foods: [.exampleFoodEntry, .exampleFoodEntry2]
//    )
//}
