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
                meals = fetchedMeals
                isLoading = false
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
    
    func refreshMeals() {
        loadMeals()
    }
    
    var totalCaloriesToday: Double {
        let calendar = Calendar.current
        let today = Date()
        
        return meals.filter { meal in
            // Handle both mealTime (String?) and date (Date) fields
            if let mealTime = meal.mealTime {
                let formatter = ISO8601DateFormatter()
                guard let mealDate = formatter.date(from: mealTime) else { return false }
                return calendar.isDate(mealDate, inSameDayAs: today)
            } else {
                return calendar.isDate(meal.date, inSameDayAs: today)
            }
        }.reduce(0) { $0 + ($1.totalCalories ?? 0) }
    }
    
    var totalCaloriesThisWeek: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        return meals.filter { meal in
            // Handle both mealTime (String?) and date (Date) fields
            if let mealTime = meal.mealTime {
                let formatter = ISO8601DateFormatter()
                guard let mealDate = formatter.date(from: mealTime) else { return false }
                return mealDate >= startOfWeek
            } else {
                return meal.date >= startOfWeek
            }
        }.reduce(0) { $0 + ($1.totalCalories ?? 0) }
    }
    
    var totalProteinToday: Double {
        let calendar = Calendar.current
        let today = Date()
        
        return meals.filter { meal in
            // Handle both mealTime (String?) and date (Date) fields
            if let mealTime = meal.mealTime {
                let formatter = ISO8601DateFormatter()
                guard let mealDate = formatter.date(from: mealTime) else { return false }
                return calendar.isDate(mealDate, inSameDayAs: today)
            } else {
                return calendar.isDate(meal.date, inSameDayAs: today)
            }
        }.compactMap { $0.totalProtein }.reduce(0, +)
    }
    
    var mealsByType: [MealType: [Meal]] {
        Dictionary(grouping: meals) { meal in
            meal.mealType ?? .other
        }
    }
    
    var todaysMeals: [Meal] {
        let calendar = Calendar.current
        let today = Date()
        
        return meals.filter { meal in
            // Handle both mealTime (String?) and date (Date) fields
            if let mealTime = meal.mealTime {
                let formatter = ISO8601DateFormatter()
                guard let mealDate = formatter.date(from: mealTime) else { return false }
                return calendar.isDate(mealDate, inSameDayAs: today)
            } else {
                return calendar.isDate(meal.date, inSameDayAs: today)
            }
        }
    }
}
