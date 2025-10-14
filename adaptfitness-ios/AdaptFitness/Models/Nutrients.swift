//
//  Nutrients.swift
//  AdaptFitness
//
//  Created by csuftitan on 10/13/25.
//

import SwiftUI

struct Nutrients: Codable {
    var barcode: String?
    var name: String
    var calories: Double
    var protein: Double
    var carbohydrates: Double
    var fat: Double
    var fiber: Double
    var sugar: Double
    var sodium: Double
    var vitaminD: Double
    var vitaminC: Double
}

extension Nutrients {
    static let exampleNutrients = Nutrients(
        barcode: "0123456789012",
        name: "Grilled Chicken Breast",
        calories: 165,
        protein: 31,
        carbohydrates: 0,
        fat: 3.6,
        fiber: 0,
        sugar: 0,
        sodium: 74,
        vitaminD: 0,
        vitaminC: 0
    )
    
    static let exampleNutrients2 = Nutrients(
        barcode: "0987654321098",
        name: "Brown Rice",
        calories: 216,
        protein: 5,
        carbohydrates: 45,
        fat: 1.8,
        fiber: 3.5,
        sugar: 0.7,
        sodium: 10,
        vitaminD: 0,
        vitaminC: 0
    )
}
