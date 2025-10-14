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
}

extension Goal {
    static let exampleActivityGoal = Goal(
        id: UUID().uuidString,
        type: "activity",
        goalAmount: 10000.0,
        goalUnits: "steps",
        window: "weekly"
    )
}

extension Goal {
    static let exampleTimeGoal = Goal(
        id: UUID().uuidString,
        type: "nutrition",
        goalAmount: 100.0,
        goalUnits: "protein",
        window: "weekly"
    )
}
