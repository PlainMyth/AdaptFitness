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
        guard let token = authManager.authToken else {
            error = "Not authenticated"
            return
        }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                let fetchedMeals = try await apiService.getMeals(token: token)
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
            let formatter = ISO8601DateFormatter()
            guard let mealDate = formatter.date(from: meal.mealTime) else { return false }
            return calendar.isDate(mealDate, inSameDayAs: today)
        }.reduce(0) { $0 + $1.totalCalories }
    }
    
    var totalCaloriesThisWeek: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        return meals.filter { meal in
            let formatter = ISO8601DateFormatter()
            guard let mealDate = formatter.date(from: meal.mealTime) else { return false }
            return mealDate >= startOfWeek
        }.reduce(0) { $0 + $1.totalCalories }
    }
    
    var totalProteinToday: Double {
        let calendar = Calendar.current
        let today = Date()
        
        return meals.filter { meal in
            let formatter = ISO8601DateFormatter()
            guard let mealDate = formatter.date(from: meal.mealTime) else { return false }
            return calendar.isDate(mealDate, inSameDayAs: today)
        }.compactMap { $0.totalProtein }.reduce(0, +)
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
        
        return meals.filter { meal in
            let formatter = ISO8601DateFormatter()
            guard let mealDate = formatter.date(from: meal.mealTime) else { return false }
            return calendar.isDate(mealDate, inSameDayAs: today)
        }
    }
}
