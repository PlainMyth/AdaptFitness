//
//  MealTrackingView.swift
//  AdaptFitness
//

import SwiftUI

struct MealTrackingView: View {
    @StateObject private var mealViewModel = MealViewModel()
    @StateObject private var authManager = AuthManager.shared
    @State private var showingFoodSelection = false
    @State private var selectedFood: SimplifiedFoodItem?
    @State private var showingNutritionFacts = false
    
    // User's daily macro goals (could come from user profile or default values)
    private let dailyGoalProtein: Double = 150
    private let dailyGoalCarbs: Double = 200
    private let dailyGoalFat: Double = 65
    
    // Helper method to calculate today's macros
    private func calculateTodayMacros() -> (protein: Double, carbs: Double, fat: Double) {
        let todayMeals = mealViewModel.todaysMeals
        let protein = todayMeals.reduce(0.0) { $0 + $1.totalProtein }
        let carbs = todayMeals.reduce(0.0) { $0 + $1.totalCarbs }
        let fat = todayMeals.reduce(0.0) { $0 + $1.totalFat }
        return (protein, carbs, fat)
    }
    
    // Helper method to calculate progress
    private func calculateProgress(consumed: Double, goal: Double) -> Double {
        guard goal > 0 else { return 0 }
        return min(consumed / goal, 1.0)
    }
    
    // Helper method to calculate remaining
    private func calculateLeft(consumed: Double, goal: Double) -> Double {
        return max(0, goal - consumed)
    }
    
    var body: some View {
        let todayMacros = calculateTodayMacros()
        let totalConsumed = todayMacros.protein + todayMacros.carbs + todayMacros.fat
        let totalGoal = dailyGoalProtein + dailyGoalCarbs + dailyGoalFat
        let overallProgress = calculateProgress(consumed: totalConsumed, goal: totalGoal)
        
        return NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Daily Progress Overview
                    dailyProgressSection(overallProgress: overallProgress)
                    
                    // Macronutrient Progress Bars
                    macroProgressSection(todayMacros: todayMacros)
                    
                    // Today's Meals
                    todaysMealsSection()
                }
                .padding(.vertical)
            }
            .navigationTitle("Track (5/10)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        // Handle back navigation
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingFoodSelection = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingFoodSelection) {
                FoodSelectionView(selectedFood: $selectedFood)
            }
            .sheet(isPresented: $showingNutritionFacts) {
                if let food = selectedFood {
                    NutritionFactsView(food: food)
                }
            }
            .onChange(of: selectedFood?.id) { _ in
                if selectedFood != nil {
                    showingNutritionFacts = true
                    showingFoodSelection = false
                }
            }
            .onAppear {
                mealViewModel.loadMeals()
            }
        }
    }
    
    // MARK: - View Builders
    
    private func dailyProgressSection(overallProgress: Double) -> some View {
        HStack(spacing: 20) {
            // Donut Chart showing overall progress
            SimpleDonutChart(
                progress: overallProgress,
                color: .blue,
                lineWidth: 12
            )
            .frame(width: 120, height: 120)
            
            // Streak Card
            streakCard()
        }
        .padding(.horizontal)
    }
    
    private func streakCard() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("\(authManager.currentUser?.loginStreak ?? 0) Day Streak!")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            Text("Keep Going!")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func macroProgressSection(todayMacros: (protein: Double, carbs: Double, fat: Double)) -> some View {
        VStack(spacing: 16) {
            MacroProgressBar(
                label: "Protein",
                consumed: todayMacros.protein,
                goal: dailyGoalProtein,
                left: calculateLeft(consumed: todayMacros.protein, goal: dailyGoalProtein),
                unit: "g",
                color: .orange
            )
            
            MacroProgressBar(
                label: "Carbs",
                consumed: todayMacros.carbs,
                goal: dailyGoalCarbs,
                left: calculateLeft(consumed: todayMacros.carbs, goal: dailyGoalCarbs),
                unit: "g",
                color: .green
            )
            
            MacroProgressBar(
                label: "Fats",
                consumed: todayMacros.fat,
                goal: dailyGoalFat,
                left: calculateLeft(consumed: todayMacros.fat, goal: dailyGoalFat),
                unit: "g",
                color: .red
            )
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func todaysMealsSection() -> some View {
        if !mealViewModel.todaysMeals.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Today's Meals")
                    .font(.headline)
                    .padding(.horizontal)
                
                ForEach(mealViewModel.todaysMeals.prefix(3)) { meal in
                    TodayMealRow(meal: meal)
                        .padding(.horizontal)
                }
                
                if mealViewModel.todaysMeals.count > 3 {
                    NavigationLink(destination: MealListView()) {
                        Text("View All (\(mealViewModel.todaysMeals.count) meals)")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.top)
        }
    }
}

struct MacroProgressBar: View {
    let label: String
    let consumed: Double
    let goal: Double
    let left: Double
    let unit: String
    let color: Color
    
    private var progress: Double {
        min(consumed / goal, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(Int(left))\(unit) \(label) Left")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(Int(consumed))/\(Int(goal))\(unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 20)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TodayMealRow: View {
    let meal: Meal
    
    var body: some View {
        HStack(spacing: 12) {
            // Meal icon
            if let mealTypeString = meal.mealType,
               let mealType = MealType(rawValue: mealTypeString) {
                Image(systemName: mealType.icon)
                    .foregroundColor(.orange)
                    .font(.title3)
                    .frame(width: 40, height: 40)
                    .background(Color.orange.opacity(0.1))
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.name)
                    .font(.headline)
                
                if let mealTypeString = meal.mealType,
                   let mealType = MealType(rawValue: mealTypeString) {
                    Text(mealType.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(meal.totalCalories)) Cal")
                    .font(.headline)
                
                Text("P:\(Int(meal.totalProtein))g C:\(Int(meal.totalCarbs))g F:\(Int(meal.totalFat))g")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    MealTrackingView()
}

