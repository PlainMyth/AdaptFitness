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
    
    // Mock goals data matching Figma design
    @State private var goals: [MealTrackerGoal] = [
        MealTrackerGoal(id: "1", name: "Walking", progress: 0.75, remaining: "4.2 km left", icon: "figure.walk", color: .green),
        MealTrackerGoal(id: "2", name: "Stretching", progress: 0.25, remaining: "16 Days left", icon: "figure.flexibility", color: .purple),
        MealTrackerGoal(id: "3", name: "Food Diversity", progress: 0.50, remaining: "12 left", icon: "leaf.fill", color: .orange),
        MealTrackerGoal(id: "4", name: "Workout Days", progress: 0.90, remaining: "3 left", icon: "dumbbell.fill", color: .blue)
    ]
    
    private var groupedMeals: [(day: Date, meals: [Meal])] {
        mealViewModel.meals.groupedByDayDescending()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Header
                    HStack {
                        Text("Welcome Back!")
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Goal Progress Circles
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(goals) { goal in
                                GoalProgressCircle(goal: goal)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Your Goals Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Goals")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Button(action: {
                            showingAddGoal = true
                        }) {
                            HStack {
                                Spacer()
                                Text("Add New")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    // Food Log Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Food Log")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if groupedMeals.isEmpty {
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
                            ForEach(groupedMeals, id: \.day) { day, dayMeals in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(formatDay(day))
                                        .font(.headline)
                                        .padding(.horizontal)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(dayMeals) { meal in
                                                FoodLogCard(meal: meal)
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
                FoodSelectionView(selectedFood: .constant(nil))
            }
            .sheet(isPresented: $showingManualEntry) {
                AddMealView { newMeal in
                    mealViewModel.addMeal(newMeal)
                    mealViewModel.loadMeals() // Refresh the meals list
                }
            }
            .sheet(isPresented: $showingMealTracking) {
                MealTrackingView()
            }
            .sheet(isPresented: $showingAddGoal) {
                // TODO: Add goal form
                Text("Add Goal Form")
            }
            .confirmationDialog("Add Food", isPresented: $showingAddMealOptions, titleVisibility: .visible) {
                Button("Search Food Database") {
                    showingFoodSelection = true
                }
                
                Button("Enter Manually") {
                    showingManualEntry = true
                }
                
                Button("Cancel", role: .cancel) { }
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
                .padding(.bottom, 100)
            }
            .onAppear {
                mealViewModel.loadMeals()
            }
        }
    }
    
    private func formatDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/dd" // e.g., "5/09"
        return formatter.string(from: date)
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
    }
}

#Preview {
    MealTrackerMainView()
}

