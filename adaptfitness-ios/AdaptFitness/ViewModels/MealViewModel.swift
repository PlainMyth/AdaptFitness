//
//  MealViewModel.swift
//  AdaptFitness
//
//  Created by AI Assistant
//

import Foundation
import SwiftUI
import Combine

@MainActor
class MealViewModel: ObservableObject {
    @Published var meals: [Meal] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let authManager = AuthManager.shared
    private let apiService = APIService.shared
    
    func loadMeals() {
        // Check if user is authenticated
        guard authManager.isAuthenticated else {
            error = "Not authenticated"
            return
        }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                // Use the new APIService.request() method
                let fetchedMeals: [Meal] = try await apiService.request(
                    endpoint: "/meals",
                    method: .get,
                    requiresAuth: true
                )
                await MainActor.run {
                    meals = fetchedMeals
                    print("📥 Loaded \(fetchedMeals.count) meals from API")
                    for meal in fetchedMeals {
                        print("  - \(meal.name): mealTime='\(meal.mealTime)', date=\(meal.date?.description ?? "nil")")
                    }
                    isLoading = false
                }
            } catch {
                self.error = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    func addMeal(_ meal: Meal) {
        meals.insert(meal, at: 0)
    }
    
    func deleteMeals(at offsets: IndexSet) {
        // Note: In a real app, you'd also call the API to delete from the server
        meals.remove(atOffsets: offsets)
    }
    
    func deleteMeal(_ meal: Meal) async {
        guard authManager.isAuthenticated,
              let token = authManager.authToken else {
            error = "Not authenticated"
            return
        }
        
        Task {
            do {
                try await apiService.deleteMeal(id: meal.id, token: token)
                await MainActor.run {
                    meals.removeAll { $0.id == meal.id }
                }
            } catch {
                await MainActor.run {
                    self.error = "Failed to delete meal: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func refreshMeals() {
        loadMeals()
    }
    
    var totalCaloriesToday: Double {
        let calendar = Calendar.current
        let today = Date()
        
        return meals.filter { meal in
            guard let mealDate = meal.date else { return false }
            return calendar.isDate(mealDate, inSameDayAs: today)
        }.reduce(0) { $0 + $1.totalCalories }
    }
    
    var totalCaloriesThisWeek: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        return meals.filter { meal in
            guard let mealDate = meal.date else { return false }
            return mealDate >= startOfWeek
        }.reduce(0) { $0 + $1.totalCalories }
    }
    
    var totalProteinToday: Double {
        let calendar = Calendar.current
        let today = Date()
        
        return meals.filter { meal in
            guard let mealDate = meal.date else { return false }
            return calendar.isDate(mealDate, inSameDayAs: today)
        }.reduce(0) { $0 + $1.totalProtein }
    }
    
    var mealsByType: [MealType: [Meal]] {
        Dictionary(grouping: meals) { meal in
            if let mealTypeString = meal.mealType,
               let mealType = MealType(rawValue: mealTypeString) {
                return mealType
            }
            return .other
        }
    }
    
    var todaysMeals: [Meal] {
        let calendar = Calendar.current
        let today = Date()
        
        let filtered = meals.filter { meal in
            guard let mealDate = meal.date else {
                print("⚠️ Meal '\(meal.name)' has no valid date. mealTime: '\(meal.mealTime)'")
                return false
            }
            let isToday = calendar.isDate(mealDate, inSameDayAs: today)
            if !isToday {
                print("📅 Meal '\(meal.name)' is not today. Date: \(mealDate), Today: \(today)")
            }
            return isToday
        }
        
        print("✅ Found \(filtered.count) meals for today out of \(meals.count) total meals")
        return filtered
    }
}
