//
//  NutritionFactsView.swift
//  AdaptFitness
//

import SwiftUI

struct NutritionFactsView: View {
    let food: SimplifiedFoodItem
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var authManager = AuthManager.shared
    
    @State private var isAddingToMeal = false
    @State private var showMealTypePicker = false
    @State private var selectedMealType: MealType = .other
    @State private var errorMessage: String?
    
    private var nutritionInfo: NutritionInfo {
        food.nutritionPerServing ?? food.nutritionPer100g
    }
    
    private var totalMacros: Double {
        nutritionInfo.protein + nutritionInfo.carbs + nutritionInfo.fat
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Food Image
                    if let imageUrlString = food.imageUrl,
                       let imageUrl = URL(string: imageUrlString) {
                        AsyncImage(url: imageUrl) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(height: 200)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure:
                                Image(systemName: "photo")
                                    .font(.system(size: 80))
                                    .foregroundColor(.gray)
                                    .frame(height: 200)
                            @unknown default:
                                Image(systemName: "photo")
                                    .font(.system(size: 80))
                                    .foregroundColor(.gray)
                                    .frame(height: 200)
                            }
                        }
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .clipped()
                    } else {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                    }
                    
                    // Food Name
                    VStack(spacing: 4) {
                        Text(food.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if let brand = food.brand {
                            Text("(\(brand))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Macros Breakdown with Donut Chart
                    HStack(spacing: 20) {
                        // Macros labels
                        VStack(alignment: .leading, spacing: 12) {
                            MacroRow(label: "Carbs", value: nutritionInfo.carbs, unit: "g", color: .green)
                            MacroRow(label: "Fats", value: nutritionInfo.fat, unit: "g", color: .red)
                            MacroRow(label: "Protein", value: nutritionInfo.protein, unit: "g", color: .orange)
                        }
                        
                        Spacer()
                        
                        // Donut Chart
                        NutritionDonutChart(
                            protein: nutritionInfo.protein,
                            carbs: nutritionInfo.carbs,
                            fat: nutritionInfo.fat
                        )
                        .frame(width: 120, height: 120)
                    }
                    .padding(.horizontal)
                    
                    // Additional Nutrition Info
                    VStack(alignment: .leading, spacing: 8) {
                        if let fiber = nutritionInfo.fiber {
                            NutritionRow(label: "Fiber", value: String(format: "%.1fg", fiber))
                        }
                        
                        if let sugar = nutritionInfo.sugar {
                            NutritionRow(label: "Sugar", value: String(format: "%.1fg", sugar))
                        }
                        
                        if let sodium = nutritionInfo.sodium {
                            NutritionRow(label: "Sodium", value: String(format: "%.0fmg", sodium))
                        }
                        
                        NutritionRow(label: "Calories", value: "\(Int(nutritionInfo.calories)) kcal")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Nutritional Facts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isAddingToMeal {
                        ProgressView()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 12) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                    
                    Button("Add") {
                        addFoodToMeal()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    .disabled(isAddingToMeal)
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .sheet(isPresented: $showMealTypePicker) {
                MealTypeSelectionSheet(
                    selectedMealType: $selectedMealType,
                    onSelect: {
                        showMealTypePicker = false
                        addFoodToMealWithType()
                    }
                )
            }
        }
    }
    
    private func addFoodToMeal() {
        // Show meal type picker first
        showMealTypePicker = true
    }
    
    private func addFoodToMealWithType() {
        guard let token = authManager.authToken else {
            errorMessage = "Not authenticated"
            return
        }
        
        isAddingToMeal = true
        errorMessage = nil
        
        let formatter = ISO8601DateFormatter()
        let now = Date()
        
        // Use serving size if available, otherwise use 100g
        let calories = nutritionInfo.calories
        let protein = nutritionInfo.protein
        let carbs = nutritionInfo.carbs
        let fat = nutritionInfo.fat
        
        let mealRequest = CreateMealRequest(
            name: food.name,
            description: food.brand != nil ? "Brand: \(food.brand!)" : nil,
            mealTime: formatter.string(from: now),
            totalCalories: calories,
            mealType: selectedMealType.rawValue,
            totalProtein: protein,
            totalCarbs: carbs,
            totalFat: fat,
            totalFiber: nutritionInfo.fiber,
            totalSugar: nutritionInfo.sugar,
            totalSodium: nutritionInfo.sodium,
            servingSize: food.servingSize,
            servingUnit: food.servingUnit
        )
        
        Task {
            do {
                _ = try await APIService.shared.createMeal(mealRequest, token: token)
                await MainActor.run {
                    isAddingToMeal = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to add meal: \(error.localizedDescription)"
                    isAddingToMeal = false
                }
            }
        }
    }
}

struct MacroRow: View {
    let label: String
    let value: Double
    let unit: String
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(label)
                .font(.subheadline)
            
            Spacer()
            
            Text("\(Int(value))\(unit)")
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

struct NutritionRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct MealTypeSelectionSheet: View {
    @Binding var selectedMealType: MealType
    let onSelect: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(MealType.allCases, id: \.self) { mealType in
                    HStack {
                        Image(systemName: mealType.icon)
                            .foregroundColor(.orange)
                            .frame(width: 30)
                        
                        Text(mealType.displayName)
                            .font(.headline)
                        
                        Spacer()
                        
                        if selectedMealType == mealType {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedMealType = mealType
                        onSelect()
                    }
                }
            }
            .navigationTitle("Select Meal Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let sampleFood = SimplifiedFoodItem(
        id: "123",
        name: "Chicken Sandwich",
        brand: "Chick-fil-a",
        category: "Fast Food",
        imageUrl: nil,
        servingSize: 100,
        servingUnit: "g",
        nutritionPer100g: NutritionInfo(
            calories: 620,
            protein: 32,
            carbs: 19,
            fat: 12,
            fiber: 2,
            sugar: 5,
            sodium: 1200
        ),
        nutritionPerServing: nil
    )
    
    NutritionFactsView(food: sampleFood)
}

