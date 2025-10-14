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
    var startDate: Date
    var endDate: Date?
    var foods: [FoodEntry]
}

extension Meal {
    static let example = Meal(
        id: UUID().uuidString,
        userId: "user123",
        startDate: Date(),
        endDate: nil,
        foods: [.exampleFoodEntry, .exampleFoodEntry2]
    )
}
