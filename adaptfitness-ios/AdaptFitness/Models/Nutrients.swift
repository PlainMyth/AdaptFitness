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
    var servingSize: Double
    var servingUnit: String
    var servingText: String?
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
        vitaminC: 0,
        servingSize: 100,
        servingUnit: "g",
        servingText: "100 g (about 1 small chicken breast)"
    )
    
    static let exampleNutrients2 = Nutrients(
        barcode: "0987654321098",
        name: "Brown Rice (Cooked)",
        calories: 216,
        protein: 5,
        carbohydrates: 45,
        fat: 1.8,
        fiber: 3.5,
        sugar: 0.7,
        sodium: 10,
        vitaminD: 0,
        vitaminC: 0,
        servingSize: 195,
        servingUnit: "g",
        servingText: "1 cup cooked (195 g)"
    )
    
    static let exampleNutrients3 = Nutrients(
        barcode: "0555555555555",
        name: "Whole Milk",
        calories: 150,
        protein: 8,
        carbohydrates: 12,
        fat: 8,
        fiber: 0,
        sugar: 12,
        sodium: 120,
        vitaminD: 2.5,
        vitaminC: 0,
        servingSize: 240,
        servingUnit: "ml",
        servingText: "1 cup (240 ml)"
    )
    
    static let exampleNutrients4 = Nutrients(
        barcode: "0999999999999",
        name: "Apple",
        calories: 95,
        protein: 0.5,
        carbohydrates: 25,
        fat: 0.3,
        fiber: 4.4,
        sugar: 19,
        sodium: 1,
        vitaminD: 0,
        vitaminC: 8.4,
        servingSize: 182,
        servingUnit: "g",
        servingText: "1 medium apple (182 g)"
    )
}
