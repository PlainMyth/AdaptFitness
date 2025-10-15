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
    var date: Date
    var type: String
    var foods: [FoodEntry]
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
            foods: [FoodEntry.exampleFoodEntries[0], FoodEntry.exampleFoodEntries[1]]
        ),
        Meal(
            id: UUID().uuidString,
            userId: "user123",
            date: Date().addingTimeInterval(-86400),
            type: "breakfast",
            foods: [FoodEntry.exampleFoodEntries[2], FoodEntry.exampleFoodEntries[3]]
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
