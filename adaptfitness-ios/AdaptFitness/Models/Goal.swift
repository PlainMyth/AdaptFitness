//
//  Goal.swift
//  AdaptFitness
//
//  Created by csuftitan on 10/13/25.
//

import SwiftUI

struct Goal: Codable, Identifiable {
    var id: String
    var type: String  // e.g. "Activity", "Weight", "Nutrition"
    var goalAmount: Double
    var goalUnits: String  // e.g. "lbs", "steps", "time"
    var window: String     // e.g. "weekly", "monthly"
    var icon: String
    var progress: Double
}

extension Goal {
    static let exampleGoals: [Goal] = [
        Goal(
            id: UUID().uuidString,
            type: "Activity",
            goalAmount: 10000,
            goalUnits: "steps",
            window: "daily",
            icon: "figure.walk",
            progress: 9500
        ),
        Goal(
            id: UUID().uuidString,
            type: "Nutrition",
            goalAmount: 2000,
            goalUnits: "calories",
            window: "daily",
            icon: "flame.fill",
            progress: 1250
        ),
        Goal(
            id: UUID().uuidString,
            type: "Sleep",
            goalAmount: 8,
            goalUnits: "hours",
            window: "daily",
            icon: "bed.double.fill",
            progress: 4
        )
    ]
}
