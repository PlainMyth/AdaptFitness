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
    
    // Manual initializer for creating instances directly
    init(
        id: String,
        name: String,
        brand: String? = nil,
        category: String? = nil,
        imageUrl: String? = nil,
        servingSize: Double? = nil,
        servingUnit: String? = nil,
        nutritionPer100g: NutritionInfo,
        nutritionPerServing: NutritionInfo? = nil
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.category = category
        self.imageUrl = imageUrl
        self.servingSize = servingSize
        self.servingUnit = servingUnit
        self.nutritionPer100g = nutritionPer100g
        self.nutritionPerServing = nutritionPerServing
    }
    
    // Custom decoder to handle servingSize as Double, String, or null
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        brand = try container.decodeIfPresent(String.self, forKey: .brand)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        servingUnit = try container.decodeIfPresent(String.self, forKey: .servingUnit)
        nutritionPer100g = try container.decode(NutritionInfo.self, forKey: .nutritionPer100g)
        nutritionPerServing = try container.decodeIfPresent(NutritionInfo.self, forKey: .nutritionPerServing)
        
        // Handle servingSize which might be Double, String, or null
        if let doubleValue = try? container.decode(Double.self, forKey: .servingSize) {
            servingSize = doubleValue
        } else if let stringValue = try? container.decode(String.self, forKey: .servingSize),
                  let parsedDouble = Double(stringValue) {
            servingSize = parsedDouble
        } else {
            servingSize = nil
        }
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

