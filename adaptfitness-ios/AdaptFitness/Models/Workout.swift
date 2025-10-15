//
//  Workout.swift
//  AdaptFitness
//
//  Created by csuftitan on 10/13/25.
//

import SwiftUI

//struct Workout: Codable {
//    var name: String
//    var calories: Double?
//}

struct Workout: Identifiable {
    let id = UUID()
    let name: String
    let intensity: String
    let calories: String
    let systemImage: String
}

extension Workout {
    static let workout: [Workout] = [
        Workout(
            name: "Morning Run",
            intensity: "High",
            calories: "400 kcal",
            systemImage: "figure.run"
        ),
        Workout(
            name: "Yoga Flow",
            intensity: "Low",
            calories: "180 kcal",
            systemImage: "figure.cooldown"
        ),
        Workout(
            name: "Strength Training",
            intensity: "Medium",
            calories: "350 kcal",
            systemImage: "dumbbell"
        ),
        Workout(
            name: "Cycling",
            intensity: "High",
            calories: "500 kcal",
            systemImage: "bicycle"
        ),
        Workout(
            name: "Swimming",
            intensity: "Medium",
            calories: "420 kcal",
            systemImage: "figure.pool.swim"
        )
    ]
}
