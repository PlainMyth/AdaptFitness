//
//  APIService.swift
//  AdaptFitness
//
//  Created by AI Assistant
//

import Foundation

class APIService: ObservableObject {
    static let shared = APIService()
    
    // Universal configuration that works for everyone
    // - iOS Simulator: Uses localhost (works universally)
    // - Physical Device: Uses production URL (works from anywhere)
    // - Can be overridden via environment variables or build settings
    private var baseURL: String {
        // Check if running on simulator
        #if targetEnvironment(simulator)
        // Simulator can connect to localhost - works for everyone
        return "http://localhost:3000"
        #else
        // Physical device uses production URL - works universally
        return "https://adaptfitness-production.up.railway.app"
        #endif
    }
    
    private let session = URLSession.shared
    
    private init() {}
    
    // MARK: - Authentication
    
    func login(email: String, password: String) async throws -> AuthResponse {
        let request = LoginRequest(email: email, password: password)
        return try await performRequest(
            endpoint: "/auth/login",
            method: "POST",
            body: request,
            responseType: AuthResponse.self
        )
    }
    
    func register(user: RegisterRequest) async throws -> AuthResponse {
        return try await performRequest(
            endpoint: "/auth/register",
            method: "POST",
            body: user,
            responseType: AuthResponse.self
        )
    }
    
    // MARK: - Workouts
    
    func getWorkouts(token: String) async throws -> [Workout] {
        return try await performAuthenticatedRequest(
            endpoint: "/workouts",
            method: "GET",
            token: token,
            responseType: [Workout].self
        )
    }
    
    func createWorkout(_ workout: CreateWorkoutRequest, token: String) async throws -> Workout {
        return try await performAuthenticatedRequest(
            endpoint: "/workouts",
            method: "POST",
            body: workout,
            token: token,
            responseType: Workout.self
        )
    }
    
    func getWorkoutStreak(token: String) async throws -> WorkoutStreak {
        return try await performAuthenticatedRequest(
            endpoint: "/workouts/streak/current",
            method: "GET",
            token: token,
            responseType: WorkoutStreak.self
        )
    }
    
    // MARK: - Meals
    
    func getMeals(token: String) async throws -> [Meal] {
        return try await performAuthenticatedRequest(
            endpoint: "/meals",
            method: "GET",
            token: token,
            responseType: [Meal].self
        )
    }
    
    func createMeal(_ meal: CreateMealRequest, token: String) async throws -> Meal {
        return try await performAuthenticatedRequest(
            endpoint: "/meals",
            method: "POST",
            body: meal,
            token: token,
            responseType: Meal.self
        )
    }
    
    func getMealStreak(token: String) async throws -> MealStreak {
        return try await performAuthenticatedRequest(
            endpoint: "/meals/streak/current",
            method: "GET",
            token: token,
            responseType: MealStreak.self
        )
    }
    
    // MARK: - Food Search (OpenFoodFacts)
    
    func searchFoods(query: String, page: Int = 1, pageSize: Int = 20, token: String) async throws -> FoodSearchResponse {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/meals/foods/search?query=\(encodedQuery)&page=\(page)&pageSize=\(pageSize)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(FoodSearchResponse.self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
    
    func getFoodByBarcode(barcode: String, token: String) async throws -> SimplifiedFoodItem {
        return try await performAuthenticatedRequest(
            endpoint: "/meals/foods/barcode/\(barcode)",
            method: "GET",
            token: token,
            responseType: SimplifiedFoodItem.self
        )
    }
    
    // MARK: - Goal Calendar
    
    func getGoals(token: String) async throws -> [GoalCalendar] {
        return try await performAuthenticatedRequest(
            endpoint: "/goal-calendar",
            method: "GET",
            token: token,
            responseType: [GoalCalendar].self
        )
    }
    
    func getCurrentWeekGoals(token: String) async throws -> [GoalCalendar] {
        return try await performAuthenticatedRequest(
            endpoint: "/goal-calendar/current-week",
            method: "GET",
            token: token,
            responseType: [GoalCalendar].self
        )
    }
    
    func createGoal(_ goal: CreateGoalRequest, token: String) async throws -> GoalCalendar {
        return try await performAuthenticatedRequest(
            endpoint: "/goal-calendar",
            method: "POST",
            body: goal,
            token: token,
            responseType: GoalCalendar.self
        )
    }
    
    func updateGoalProgress(token: String) async throws -> [GoalCalendar] {
        return try await performAuthenticatedRequest(
            endpoint: "/goal-calendar/update-all-progress",
            method: "POST",
            token: token,
            responseType: [GoalCalendar].self
        )
    }
    
    func getGoalStatistics(token: String) async throws -> GoalStatistics {
        return try await performAuthenticatedRequest(
            endpoint: "/goal-calendar/statistics",
            method: "GET",
            token: token,
            responseType: GoalStatistics.self
        )
    }
    
    func getCalendarView(year: Int, month: Int, token: String) async throws -> CalendarView {
        return try await performAuthenticatedRequest(
            endpoint: "/goal-calendar/calendar-view?year=\(year)&month=\(month)",
            method: "GET",
            token: token,
            responseType: CalendarView.self
        )
    }
    
    // MARK: - Private Helper Methods
    
    private func performRequest<T: Codable, R: Codable>(
        endpoint: String,
        method: String,
        body: T? = nil,
        responseType: R.Type
    ) async throws -> R {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(responseType, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
    
    private func performAuthenticatedRequest<T: Codable, R: Codable>(
        endpoint: String,
        method: String,
        body: T? = nil,
        token: String,
        responseType: R.Type
    ) async throws -> R {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(responseType, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
    
    private func performAuthenticatedRequest<R: Codable>(
        endpoint: String,
        method: String,
        token: String,
        responseType: R.Type
    ) async throws -> R {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(responseType, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error with code: \(code)"
        case .decodingError:
            return "Failed to decode response"
        case .noData:
            return "No data received"
        }
    }
}
