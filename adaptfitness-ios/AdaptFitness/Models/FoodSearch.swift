//
//  FoodSearch.swift
//  AdaptFitness
//
//  Models for OpenFoodFacts API food search responses
//

import Foundation

// MARK: - Food Search Response

struct FoodSearchResponse: Codable {
    let foods: [SimplifiedFoodItem]
    let totalCount: Int
    let page: Int
    let pageSize: Int
    let totalPages: Int
    
    enum CodingKeys: String, CodingKey {
        case foods
        case totalCount
        case page
        case pageSize
        case totalPages
    }
}

// MARK: - Simplified Food Item

struct SimplifiedFoodItem: Codable, Identifiable {
    let id: String // Barcode
    let name: String
    let brand: String?
    let category: String?
    let imageUrl: String?
    let servingSize: Double?
    let servingUnit: String?
    let nutritionPer100g: NutritionInfo
    let nutritionPerServing: NutritionInfo?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case brand
        case category
        case imageUrl
        case servingSize
        case servingUnit
        case nutritionPer100g
        case nutritionPerServing
    }
}

// MARK: - Nutrition Information

struct NutritionInfo: Codable {
    let calories: Double
    let protein: Double // grams
    let carbs: Double // grams
    let fat: Double // grams
    let fiber: Double? // grams
    let sugar: Double? // grams
    let sodium: Double? // mg
}

