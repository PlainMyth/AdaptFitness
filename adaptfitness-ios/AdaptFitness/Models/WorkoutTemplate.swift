//
//  WorkoutTemplate.swift
//  AdaptFitness
//
//  Template model for workout browsing (different from actual Workout model)
//

import Foundation

struct WorkoutTemplate: Identifiable {
    let id = UUID()
    let name: String
    let intensity: String
    let calories: String
    let systemImage: String
}

