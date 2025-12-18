//
//  FoodSearchViewModel.swift
//  AdaptFitness
//

import Foundation
import SwiftUI
import Combine

@MainActor
class FoodSearchViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchResults: [SimplifiedFoodItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedFood: SimplifiedFoodItem?
    
    private let authManager = AuthManager.shared
    private let apiService = APIService.shared
    
    func searchFoods() async {
        print("🔍 ====== searchFoods() CALLED ======")
        print("🔍 Query: '\(searchQuery)'")
        print("🔍 Query length: \(searchQuery.count)")
        
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
            print("❌ Query is empty after trimming")
            errorMessage = "Please enter a search query"
            return
        }
        
        guard searchQuery.count >= 2 else {
            print("❌ Query too short: \(searchQuery.count) characters")
            errorMessage = "Search query must be at least 2 characters"
            return
        }
        
        guard let token = authManager.authToken else {
            print("❌ No authentication token")
            errorMessage = "Not authenticated. Please log in."
            return
        }
        
        print("✅ All guards passed. Starting search...")
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.searchFoods(
                query: searchQuery,
                page: 1,
                pageSize: 15, // Reduced from 20 to 15 for faster responses
                token: token
            )
            
            print("✅ Search successful: \(response.foods.count) results for '\(searchQuery)'")
            searchResults = response.foods
            
            // If we got a response but no foods, it's not an error - just no results
            if response.foods.isEmpty && response.totalCount == 0 {
                errorMessage = nil // Clear any previous errors
            }
        } catch let error as APIError {
            switch error {
            case .httpError(401, _):
                // Token expired or invalid - clear auth state
                authManager.handleTokenExpiration()
                errorMessage = "Your session has expired. Please log in again."
            case .httpError(429, _):
                errorMessage = "Too many requests. Please wait a moment before searching again."
            case .httpError(504, _):
                errorMessage = "Search timed out. The food database may be slow. Please try again."
            case .httpError(let code, let message):
                // Use custom message if available, otherwise provide default
                errorMessage = message ?? "Server error (code: \(code)). Please try again later."
            case .decodingError:
                errorMessage = "Could not process search results. Please try again or use manual entry."
            case .unauthorized:
                // No token available
                authManager.handleTokenExpiration()
                errorMessage = "Not authenticated. Please log in."
            default:
                errorMessage = "Failed to search foods: \(error.localizedDescription)"
            }
            searchResults = []
        } catch {
            // Check if the task was cancelled (this is expected behavior during debouncing)
            if error is CancellationError {
                // Task was cancelled - don't show error, this is normal during typing
                print("🔍 Search task was cancelled (expected during debouncing)")
                return
            }
            
            // Check if it's a 401 error from the error description
            let errorString = error.localizedDescription
            if errorString.contains("401") || errorString.contains("Unauthorized") || errorString.contains("Not authenticated") {
                authManager.handleTokenExpiration()
                errorMessage = "Your session has expired. Please log in again."
            } else if errorString.contains("429") || errorString.contains("Too Many Requests") {
                errorMessage = "Too many requests. Please wait a moment before searching again."
            } else if errorString.contains("cancelled") || errorString.contains("canceled") {
                // Task was cancelled - don't show error
                print("🔍 Search was cancelled (expected)")
                return
            } else if errorString.contains("decode") || errorString.contains("Failed to decode") {
                errorMessage = "Could not process search results. Please try again or use manual entry."
            } else {
                errorMessage = "Failed to search foods: \(error.localizedDescription)"
            }
            searchResults = []
        }
        
        isLoading = false
    }
    
    func getFoodByBarcode(_ barcode: String) async {
        guard !barcode.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Barcode cannot be empty"
            return
        }
        
        guard let token = authManager.authToken else {
            errorMessage = "Not authenticated. Please log in."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let food = try await apiService.getFoodByBarcode(barcode: barcode, token: token)
            selectedFood = food
        } catch {
            errorMessage = "Failed to fetch food: \(error.localizedDescription)"
            selectedFood = nil
        }
        
        isLoading = false
    }
    
    func clearSearch() {
        searchQuery = ""
        searchResults = []
        errorMessage = nil
    }
    
    func selectFood(_ food: SimplifiedFoodItem) {
        selectedFood = food
    }
}

