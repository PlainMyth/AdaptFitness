//
//  FoodEntry.swift
//  AdaptFitness
//
//  Created by csuftitan on 10/13/25.
//
import SwiftUI

struct FoodEntry: Codable, Identifiable {
    var id: String
    var name: String
    var barcode: String?
    var quantity: Double
    var unit: String  // "g", "oz", etc.
    var type: String  // "breakfast", "lunch", etc.
    var nutrients: Nutrients
}

extension FoodEntry {
    static let exampleFoodEntry = FoodEntry(
        id: UUID().uuidString,
        name: "Grilled Chicken Breast",
        barcode: "0123456789012",
        quantity: 150,
        unit: "g",
        type: "lunch",
        nutrients: .exampleNutrients
    )
    
    static let exampleFoodEntry2 = FoodEntry(
        id: UUID().uuidString,
        name: "Brown Rice",
        barcode: "0987654321098",
        quantity: 200,
        unit: "g",
        type: "lunch",
        nutrients: .exampleNutrients2
    )
}
