//
//  MealDetailView.swift
//  AdaptFitness
//
//  Meal detail view showing full meal information
//

import SwiftUI

struct MealDetailView: View {
    let meal: Meal
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: {
                                if let mealTypeString = meal.mealType,
                                   let mealType = MealType(rawValue: mealTypeString) {
                                    return mealType.icon
                                }
                                return "fork.knife"
                            }())
                                .font(.title)
                                .foregroundColor(.orange)
                            
                            VStack(alignment: .leading) {
                                Text(meal.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                if let mealTypeString = meal.mealType,
                                   let mealType = MealType(rawValue: mealTypeString) {
                                    Text(mealType.displayName)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                        }
                        
                        if let description = meal.description, !description.isEmpty {
                            Text(description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Nutrition Stats
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        NutritionCard(
                            title: "Calories",
                            value: "\(Int(meal.totalCalories))",
                            unit: "kcal",
                            icon: "flame.fill",
                            color: .orange
                        )
                        
                        NutritionCard(
                            title: "Protein",
                            value: "\(Int(meal.totalProtein))",
                            unit: "g",
                            icon: "dumbbell.fill",
                            color: .blue
                        )
                        
                        NutritionCard(
                            title: "Carbs",
                            value: "\(Int(meal.totalCarbs))",
                            unit: "g",
                            icon: "leaf.fill",
                            color: .green
                        )
                        
                        NutritionCard(
                            title: "Fat",
                            value: "\(Int(meal.totalFat))",
                            unit: "g",
                            icon: "drop.fill",
                            color: .purple
                        )
                    }
                    
                    // Timing Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Meal Time")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(formatMealTime(meal.mealTime))
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Meal Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatMealTime(_ timeString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: timeString) else { return timeString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        
        return displayFormatter.string(from: date)
    }
}

struct NutritionCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    let sampleMeal = Meal(
        id: "1",
        userId: "user1",
        name: "Breakfast",
        description: "Scrambled eggs with toast",
        mealTime: ISO8601DateFormatter().string(from: Date()),
        totalCalories: 450,
        totalProtein: 25,
        totalCarbs: 35,
        totalFat: 20,
        mealType: "breakfast"
    )
    
    MealDetailView(meal: sampleMeal)
}

