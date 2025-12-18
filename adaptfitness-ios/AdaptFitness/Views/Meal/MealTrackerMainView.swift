//
//  MealTrackerMainView.swift
//  AdaptFitness
//

import SwiftUI

struct MealTrackerMainView: View {
    @StateObject private var mealViewModel = MealViewModel()
    @StateObject private var authManager = AuthManager.shared
    @State private var showingFoodSelection = false
    @State private var showingMealTracking = false
    @State private var showingAddGoal = false
    @State private var showingManualEntry = false
    @State private var showingAddMealOptions = false
    @State private var selectedFood: SimplifiedFoodItem?
    @State private var showingNutritionFacts = false
    
    // Macro goals (in grams)
    private let dailyGoalProtein: Double = 150
    private let dailyGoalCarbs: Double = 200
    private let dailyGoalFat: Double = 65
    private let dailyGoalSugar: Double = 50
    private let dailyGoalFiber: Double = 30
    private let dailyGoalCalories: Double = 2000
    
    // Calculate macro goals based on today's meals
    private var macroGoals: [MealTrackerGoal] {
        let todayMeals = mealViewModel.todaysMeals
        
        let consumedProtein = todayMeals.reduce(0.0) { $0 + $1.totalProtein }
        let consumedCarbs = todayMeals.reduce(0.0) { $0 + $1.totalCarbs }
        let consumedFat = todayMeals.reduce(0.0) { $0 + $1.totalFat }
        let consumedSugar = todayMeals.reduce(0.0) { $0 + ($1.totalSugar ?? 0) }
        let consumedFiber = todayMeals.reduce(0.0) { $0 + ($1.totalFiber ?? 0) }
        let consumedCalories = todayMeals.reduce(0.0) { $0 + $1.totalCalories }
        
        func calculateProgress(consumed: Double, goal: Double) -> Double {
            guard goal > 0 else { return 0 }
            return min(consumed / goal, 1.0)
        }
        
        func formatConsumedGoal(consumed: Double, goal: Double, unit: String = "g") -> String {
            if unit == "Cal" {
                return String(format: "%.0f/%.0f", consumed, goal)
            }
            return String(format: "%.0f/%.0f %@", consumed, goal, unit)
        }
        
        return [
            MealTrackerGoal(
                id: "calories",
                name: "Calories",
                progress: calculateProgress(consumed: consumedCalories, goal: dailyGoalCalories),
                remaining: formatConsumedGoal(consumed: consumedCalories, goal: dailyGoalCalories, unit: "Cal"),
                icon: "flame.fill",
                color: .red
            ),
            MealTrackerGoal(
                id: "protein",
                name: "Protein",
                progress: calculateProgress(consumed: consumedProtein, goal: dailyGoalProtein),
                remaining: formatConsumedGoal(consumed: consumedProtein, goal: dailyGoalProtein),
                icon: "dumbbell.fill",
                color: .orange
            ),
            MealTrackerGoal(
                id: "carbs",
                name: "Carbs",
                progress: calculateProgress(consumed: consumedCarbs, goal: dailyGoalCarbs),
                remaining: formatConsumedGoal(consumed: consumedCarbs, goal: dailyGoalCarbs),
                icon: "leaf.fill",
                color: .green
            ),
            MealTrackerGoal(
                id: "fat",
                name: "Fat",
                progress: calculateProgress(consumed: consumedFat, goal: dailyGoalFat),
                remaining: formatConsumedGoal(consumed: consumedFat, goal: dailyGoalFat),
                icon: "drop.fill",
                color: .blue
            ),
            MealTrackerGoal(
                id: "sugar",
                name: "Sugar",
                progress: calculateProgress(consumed: consumedSugar, goal: dailyGoalSugar),
                remaining: formatConsumedGoal(consumed: consumedSugar, goal: dailyGoalSugar),
                icon: "sparkles",
                color: .purple
            ),
            MealTrackerGoal(
                id: "fiber",
                name: "Fiber",
                progress: calculateProgress(consumed: consumedFiber, goal: dailyGoalFiber),
                remaining: formatConsumedGoal(consumed: consumedFiber, goal: dailyGoalFiber),
                icon: "circle.grid.2x2.fill",
                color: .indigo
            )
        ]
    }
    
    // Group today's meals by meal type
    private var mealsByType: [(type: MealType, meals: [Meal])] {
        let todayMeals = mealViewModel.todaysMeals
        let grouped = Dictionary(grouping: todayMeals) { meal -> MealType in
            if let mealTypeString = meal.mealType,
               let mealType = MealType(rawValue: mealTypeString) {
                return mealType
            }
            return .other
        }
        
        // Order by meal type: breakfast, lunch, dinner, snack, other
        let order: [MealType] = [.breakfast, .lunch, .dinner, .snack, .other]
        return order.compactMap { type in
            if let meals = grouped[type], !meals.isEmpty {
                return (type: type, meals: meals)
            }
            return nil
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Header
                    HStack {
                        Text("Meal Logger")
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Macro Goals Progress Circles
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(macroGoals) { goal in
                                GoalProgressCircle(goal: goal)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                    
                    // Your Goals Section
//                    VStack(alignment: .leading, spacing: 12) {
//                        Text("Your Goals")
//                            .font(.title2)
//                            .fontWeight(.bold)
//                            .frame(maxWidth: .infinity, alignment: .center)
//                        
//                        Button(action: {
//                            showingAddGoal = true
//                        }) {
//                            HStack {
//                                Spacer()
//                                Text("Add New")
//                                    .font(.headline)
//                                    .foregroundColor(.white)
//                                Spacer()
//                            }
//                            .padding()
//                            .background(Color.blue)
//                            .cornerRadius(12)
//                        }
//                        .padding(.horizontal)
//                    }
//                    .padding(.top)
                    
                    // Food Log Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Food Log")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if mealsByType.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("No meals logged yet")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("Tap the barcode button to start logging meals")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            ForEach(mealsByType, id: \.type) { mealType, meals in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: mealType.icon)
                                            .foregroundColor(.orange)
                                        Text(mealType.displayName)
                                            .font(.headline)
                                    }
                                    .padding(.horizontal)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(meals) { meal in
                                                FoodLogCard(meal: meal, onDelete: {
                                                    deleteMeal(meal)
                                                })
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top)
                }
                .padding(.bottom, 80) // Space for floating button
            }
            .navigationTitle("Main Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingMealTracking = true
                    }) {
                        Image(systemName: "chart.bar.fill")
                    }
                }
            }
            .sheet(isPresented: $showingFoodSelection) {
                FoodSelectionView(selectedFood: $selectedFood)
            }
            .sheet(isPresented: $showingNutritionFacts) {
                if let food = selectedFood {
                    NutritionFactsView(food: food, onMealAdded: { newMeal in
                        // Add meal immediately to local array
                        mealViewModel.addMeal(newMeal)
                        // Then refresh from server to ensure consistency
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            mealViewModel.loadMeals()
                        }
                    })
                }
            }
            .refreshable {
                // Pull to refresh
                mealViewModel.loadMeals()
            }
            .onChange(of: selectedFood?.id) { oldValue, newValue in
                if selectedFood != nil {
                    showingFoodSelection = false
                    showingNutritionFacts = true
                }
            }
            .sheet(isPresented: $showingManualEntry) {
                AddMealView { newMeal in
                    mealViewModel.addMeal(newMeal)
                    // Refresh the meals list after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        mealViewModel.loadMeals()
                    }
                }
            }
            .sheet(isPresented: $showingMealTracking) {
                MealTrackingView()
            }
            .sheet(isPresented: $showingAddGoal) {
                // TODO: Add goal form
                Text("Add Goal Form")
            }
            .overlay(alignment: .bottomTrailing) {
                // Floating Barcode Button
                Button(action: {
                    showingAddMealOptions = true
                }) {
                    Image(systemName: "barcode")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
                .popover(isPresented: $showingAddMealOptions, attachmentAnchor: .point(.topTrailing), arrowEdge: .bottom) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Add Food")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                        
                        Divider()
                        
                        Button(action: {
                            showingAddMealOptions = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showingFoodSelection = true
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.blue)
                                    .frame(width: 24)
                                Text("Search Food Database")
                                Spacer()
                            }
                            .padding()
                        }
                        .buttonStyle(.plain)
                        
                        Divider()
                        
                        Button(action: {
                            showingAddMealOptions = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showingManualEntry = true
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                                    .frame(width: 24)
                                Text("Enter Manually")
                                Spacer()
                            }
                            .padding()
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(width: 280)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .presentationCompactAdaptation(.popover)
                }
            }
            .onAppear {
                mealViewModel.loadMeals()
            }
            .onChange(of: mealViewModel.meals.count) { oldValue, newValue in
                // Refresh when meals count changes
                print("📊 Meals count changed from \(oldValue) to \(newValue)")
                print("📊 Today's meals: \(mealViewModel.todaysMeals.count)")
            }
        }
    }
    
    private func deleteMeal(_ meal: Meal) {
        Task {
            await mealViewModel.deleteMeal(meal)
            mealViewModel.loadMeals() // Refresh the list
        }
    }
}

struct MealTrackerGoal: Identifiable {
    let id: String
    let name: String
    let progress: Double // 0.0 to 1.0
    let remaining: String
    let icon: String
    let color: Color
}

struct GoalProgressCircle: View {
    let goal: MealTrackerGoal
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                    .frame(width: 80, height: 80)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: goal.progress)
                    .stroke(
                        goal.color,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: goal.progress)
                
                // Icon in center
                Image(systemName: goal.icon)
                    .foregroundColor(goal.color)
                    .font(.system(size: 24))
            }
            
            Text(goal.name)
                .font(.caption)
                .fontWeight(.medium)
            
            Text(goal.remaining)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(width: 100)
    }
}

struct FoodLogCard: View {
    let meal: Meal
    let onDelete: () -> Void
    
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Placeholder for food image
            // In real implementation, this would show the actual food image
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
                    .frame(width: 120, height: 80)
                
                if let mealTypeString = meal.mealType,
                   let mealType = MealType(rawValue: mealTypeString) {
                    Image(systemName: mealType.icon)
                        .font(.system(size: 30))
                        .foregroundColor(.orange)
                } else {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                }
            }
            
            Text(meal.name)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(2)
                .frame(width: 120, alignment: .leading)
            
            Text("\(Int(meal.totalCalories)) Cal")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showingDeleteConfirmation = true
        }
        .confirmationDialog("Delete Meal", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete '\(meal.name)'?")
        }
    }
}

#Preview {
    MealTrackerMainView()
}

