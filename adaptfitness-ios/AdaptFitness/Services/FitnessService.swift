//
//  FitnessService.swift
//  AdaptFitness
//
//  Created by csuftitan on 10/13/25.
//

final class FitnessService {
    static let shared = FitnessService()

    func addRecord(_ record: FitnessRecord) {
        // Save locally or send to API
    }

    func calcCaloriesBurned(duration: Double, activityLevel: String) -> Double {
        // Example formula
        let multiplier = activityLevel == "high" ? 10.0 : 7.0
        return duration * multiplier
    }
}
