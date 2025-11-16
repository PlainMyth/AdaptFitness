//
//  MealDetailView.swift
//  AdaptFitness
//
//  Detail view for displaying meal information
//

import SwiftUI

struct MealDetailView: View {
    let meal: Meal
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Meal Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(meal.name ?? "Unnamed Meal")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        if let description = meal.description, !description.isEmpty {
                            Text(description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        if let mealType = meal.mealType {
                            HStack {
                                Image(systemName: mealType.icon)
                                Text(mealType.displayName)
                            }
                            .font(.subheadline)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    
                    // Nutrition Information
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Nutrition Information")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            NutritionRow(label: "Calories", value: meal.totalCalories, unit: "kcal")
                            NutritionRow(label: "Protein", value: meal.totalProtein, unit: "g")
                            NutritionRow(label: "Carbs", value: meal.totalCarbs, unit: "g")
                            NutritionRow(label: "Fat", value: meal.totalFat, unit: "g")
                            NutritionRow(label: "Fiber", value: meal.totalFiber, unit: "g")
                            NutritionRow(label: "Sugar", value: meal.totalSugar, unit: "g")
                            NutritionRow(label: "Sodium", value: meal.totalSodium, unit: "mg")
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Meal Time
                    if let mealTime = meal.mealTime {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Meal Time")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text(formatMealTime(mealTime))
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
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

struct NutritionRow: View {
    let label: String
    let value: Double?
    let unit: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            if let value = value {
                Text("\(Int(value)) \(unit)")
                    .fontWeight(.medium)
            } else {
                Text("N/A")
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    MealDetailView(meal: Meal(
        id: UUID().uuidString,
        userId: "user123",
        date: Date(),
        type: "breakfast",
        foods: [],
        name: "Scrambled Eggs",
        description: "With toast and orange juice",
        mealTime: ISO8601DateFormatter().string(from: Date()),
        totalCalories: 350,
        totalProtein: 20,
        totalCarbs: 30,
        totalFat: 15,
        totalFiber: 2,
        totalSugar: 5,
        totalSodium: 400
    ))
}

