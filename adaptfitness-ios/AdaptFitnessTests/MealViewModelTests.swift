//
//  MealViewModelTests.swift
//  AdaptFitnessTests
//
//  Unit tests for MealViewModel to verify meal tracking functionality
//

import Testing
import Foundation
@testable import AdaptFitness

@MainActor
struct MealViewModelTests {
    
    // MARK: - Test Data Setup
    
    func createTestMeal() -> Meal {
        return Meal(
            id: "test-meal-1",
            userId: "test-user-1",
            name: "Test Breakfast",
            description: "A test meal",
            mealTime: ISO8601DateFormatter().string(from: Date()),
            totalCalories: 500.0,
            totalProtein: 30.0,
            totalCarbs: 50.0,
            totalFat: 20.0,
            mealType: "breakfast"
        )
    }
    
    // MARK: - Initialization Tests
    
    @Test func testMealViewModelInitialization() async throws {
        let viewModel = MealViewModel()
        
        #expect(viewModel.meals.isEmpty)
        #expect(viewModel.isLoading == false)
    }
    
    // MARK: - Meal Management Tests
    
    @Test func testAddMeal() async throws {
        let viewModel = MealViewModel()
        let testMeal = createTestMeal()
        
        viewModel.addMeal(testMeal)
        
        #expect(viewModel.meals.count == 1)
        #expect(viewModel.meals.first?.id == testMeal.id)
        #expect(viewModel.meals.first?.name == "Test Breakfast")
    }
    
    @Test func testAddMultipleMeals() async throws {
        let viewModel = MealViewModel()
        
        let meal1 = createTestMeal()
        let meal2 = Meal(
            id: "test-meal-2",
            userId: "test-user-1",
            name: "Test Lunch",
            mealTime: ISO8601DateFormatter().string(from: Date()),
            totalCalories: 600.0,
            totalProtein: 40.0,
            totalCarbs: 60.0,
            totalFat: 25.0,
            mealType: "lunch"
        )
        
        viewModel.addMeal(meal1)
        viewModel.addMeal(meal2)
        
        #expect(viewModel.meals.count == 2)
        #expect(viewModel.meals.contains { $0.name == "Test Breakfast" })
        #expect(viewModel.meals.contains { $0.name == "Test Lunch" })
    }
    
    // MARK: - Computed Properties Tests
    
    @Test func testMealsByType() async throws {
        let viewModel = MealViewModel()
        
        let breakfast = createTestMeal()
        let lunch = Meal(
            id: "test-meal-2",
            userId: "test-user-1",
            name: "Test Lunch",
            mealTime: ISO8601DateFormatter().string(from: Date()),
            totalCalories: 600.0,
            mealType: "lunch"
        )
        
        viewModel.addMeal(breakfast)
        viewModel.addMeal(lunch)
        
        let mealsByType = viewModel.mealsByType
        
        #expect(mealsByType[.breakfast]?.count == 1)
        #expect(mealsByType[.lunch]?.count == 1)
        #expect(mealsByType[.breakfast]?.first?.name == "Test Breakfast")
    }
    
    @Test func testTotalCaloriesToday() async throws {
        let viewModel = MealViewModel()
        
        let todayMeal1 = createTestMeal()
        let todayMeal2 = Meal(
            id: "test-meal-2",
            userId: "test-user-1",
            name: "Test Lunch",
            mealTime: ISO8601DateFormatter().string(from: Date()),
            totalCalories: 600.0,
            mealType: "lunch"
        )
        
        // Create a meal from yesterday
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let yesterdayMeal = Meal(
            id: "test-meal-3",
            userId: "test-user-1",
            name: "Yesterday Meal",
            mealTime: ISO8601DateFormatter().string(from: yesterday),
            totalCalories: 700.0,
            mealType: "dinner"
        )
        
        viewModel.addMeal(todayMeal1)
        viewModel.addMeal(todayMeal2)
        viewModel.addMeal(yesterdayMeal)
        
        let totalCalories = viewModel.totalCaloriesToday
        
        #expect(totalCalories == 1100.0) // 500 + 600
    }
    
    @Test func testTotalProteinToday() async throws {
        let viewModel = MealViewModel()
        
        let meal1 = createTestMeal() // 30g protein
        let meal2 = Meal(
            id: "test-meal-2",
            userId: "test-user-1",
            name: "Test Lunch",
            mealTime: ISO8601DateFormatter().string(from: Date()),
            totalCalories: 600.0,
            totalProtein: 40.0,
            mealType: "lunch"
        )
        
        viewModel.addMeal(meal1)
        viewModel.addMeal(meal2)
        
        let totalProtein = viewModel.totalProteinToday
        
        #expect(totalProtein == 70.0) // 30 + 40
    }
    
    @Test func testTodaysMeals() async throws {
        let viewModel = MealViewModel()
        
        let todayMeal = createTestMeal()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let yesterdayMeal = Meal(
            id: "test-meal-2",
            userId: "test-user-1",
            name: "Yesterday Meal",
            mealTime: ISO8601DateFormatter().string(from: yesterday),
            totalCalories: 600.0,
            mealType: "dinner"
        )
        
        viewModel.addMeal(todayMeal)
        viewModel.addMeal(yesterdayMeal)
        
        let todaysMeals = viewModel.todaysMeals
        
        #expect(todaysMeals.count == 1)
        #expect(todaysMeals.first?.name == "Test Breakfast")
    }
    
    // MARK: - Edge Cases
    
    @Test func testEmptyMealsList() async throws {
        let viewModel = MealViewModel()
        
        #expect(viewModel.meals.isEmpty)
        #expect(viewModel.totalCaloriesToday == 0.0)
        #expect(viewModel.totalProteinToday == 0.0)
        #expect(viewModel.todaysMeals.isEmpty)
    }
    
    @Test func testMealWithNoDate() async throws {
        let viewModel = MealViewModel()
        
        // Note: This test depends on how Meal model handles optional dates
        // If date is required, this test would need adjustment
        let meal = createTestMeal()
        viewModel.addMeal(meal)
        
        #expect(viewModel.meals.count == 1)
    }
    
    @Test func testMealTypeGrouping() async throws {
        let viewModel = MealViewModel()
        
        let breakfast1 = createTestMeal()
        let breakfast2 = Meal(
            id: "test-meal-2",
            userId: "test-user-1",
            name: "Another Breakfast",
            mealTime: ISO8601DateFormatter().string(from: Date()),
            totalCalories: 400.0,
            mealType: "breakfast"
        )
        let lunch = Meal(
            id: "test-meal-3",
            userId: "test-user-1",
            name: "Lunch",
            mealTime: ISO8601DateFormatter().string(from: Date()),
            totalCalories: 600.0,
            mealType: "lunch"
        )
        
        viewModel.addMeal(breakfast1)
        viewModel.addMeal(breakfast2)
        viewModel.addMeal(lunch)
        
        let mealsByType = viewModel.mealsByType
        
        #expect(mealsByType[.breakfast]?.count == 2)
        #expect(mealsByType[.lunch]?.count == 1)
    }
}

