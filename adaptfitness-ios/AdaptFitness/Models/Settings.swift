//
//  Settings.swift
//  AdaptFitness
//
//  Created by csuftitan on 10/13/25.
//

import SwiftUI

struct Settings: Codable {
    var age: Int
    var gender: String
    var height: Double
    var activityLevel: String
    var tdee: Double
}

extension Settings {
    static let exampleSettings = Settings(
        age: 30,
        gender: "male",
        height: 180.0,
        activityLevel: "moderate",
        tdee: 2400.0
    )
}
