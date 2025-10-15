//
//  FitnessRecord.swift
//  AdaptFitness
//
//  Created by csuftitan on 10/13/25.
//

import SwiftUI

struct FitnessRecord: Codable, Identifiable {
    var id: String
    var date: Date
    var workoutName: String
    var duration: Double  // minutes
    var caloriesBurned: Double
}

extension FitnessRecord {
    static let exampleFitnessRecord = FitnessRecord(
        id: UUID().uuidString,
        date: Date(),
        workoutName: "Morning Run",
        duration: 45,  // minutes
        caloriesBurned: 400
    )
    
    static let exampleFitnessRecord2 = FitnessRecord(
        id: UUID().uuidString,
        date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
        workoutName: "Upper Body Strength",
        duration: 60,
        caloriesBurned: 500
    )
    
    static let exampleFitnessRecord3 = FitnessRecord(
        id: UUID().uuidString,
        date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
        workoutName: "Upper Body Strength",
        duration: 60,
        caloriesBurned: 500
    )
}

extension FitnessRecord {
    static let exampleRecords: [FitnessRecord] = [
        FitnessRecord(id: UUID().uuidString, date: Date(), workoutName: "Morning Run", duration: 45, caloriesBurned: 400),
        FitnessRecord(id: UUID().uuidString, date: Date().addingTimeInterval(-86400), workoutName: "Yoga", duration: 60, caloriesBurned: 200),
        FitnessRecord(id: UUID().uuidString, date: Date().addingTimeInterval(-172800), workoutName: "Strength Training", duration: 50, caloriesBurned: 350)
    ]
}
