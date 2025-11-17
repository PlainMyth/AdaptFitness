//
//  Meal.swift
//  AdaptFitness
//
//  Created by csuftitan on 10/13/25.
//
import SwiftUI

struct Meal: Codable, Identifiable {
    var id: String
    var userId: String
    var name: String
    var description: String?
    var mealTime: String  // ISO8601 date string from backend
    var totalCalories: Double
    var totalProtein: Double
    var totalCarbs: Double
    var totalFat: Double
    var totalFiber: Double?
    var totalSugar: Double?
    var totalSodium: Double?
    var mealType: String?  // 'breakfast', 'lunch', 'dinner', 'snack', 'other'
    var servingSize: Double?
    var servingUnit: String?
    var createdAt: String?
    var updatedAt: String?
    
    // Computed property for Date from mealTime string
    var date: Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: mealTime)
    }
    
    // Compatibility property for older code
    var type: String {
        return mealType ?? "other"
    }
    
    // Compatibility property for older code (empty array since foods aren't stored this way)
    var foods: [FoodEntry] {
        return []
    }
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
        case .dinner: return "moon.stars.fill"
        case .snack: return "leaf.fill"
        case .other: return "fork.knife"
        }
    }
}

extension Meal {
    var dayLabel: String {
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
        return "Unknown"
    }
    
    static let exampleMeals: [Meal] = [
        Meal(
            id: UUID().uuidString,
            userId: "user123",
            name: "Breakfast",
            description: nil,
            mealTime: ISO8601DateFormatter().string(from: Date()),
            totalCalories: 450,
            totalProtein: 20,
            totalCarbs: 60,
            totalFat: 15,
            mealType: "breakfast"
        )
    ]
}

extension Array where Element == Meal {
    func groupedByDayDescending() -> [(day: Date, meals: [Meal])] {
        let grouped = Dictionary(grouping: self) { meal -> Date in
            if let date = meal.date {
                return Calendar.current.startOfDay(for: date)
            }
            return Calendar.current.startOfDay(for: Date())
        }
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
