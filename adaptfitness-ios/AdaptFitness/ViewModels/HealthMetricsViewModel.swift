//
//  HealthMetricsViewModel.swift
//  AdaptFitness
//
//  ViewModel for managing health metrics data and API interactions
//
//  This ViewModel follows the MVVM pattern and is responsible for:
//  - Managing the state of health metrics data
//  - Making API calls to fetch and create health metrics
//  - Handling loading states and errors
//  - Providing a clean interface for the View to consume data
//

import Foundation
import SwiftUI
import Combine

/// ViewModel for Health Metrics feature
///
/// This class manages all business logic related to health metrics:
/// - Fetches health metrics data from the backend API
/// - Creates new health metrics entries
/// - Manages loading and error states
/// - Provides formatted data to the View
///
/// Uses `@MainActor` to ensure all UI updates happen on the main thread.
@MainActor
class HealthMetricsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    // These properties automatically update the UI when they change
    
    /// The latest health metrics entry for the current user
    /// Contains all raw measurements and calculated metrics
    @Published var latestMetrics: HealthMetrics?
    
    /// Simplified calculated metrics only (from /calculations endpoint)
    /// Used when you only need the computed values without full entry details
    @Published var calculatedMetrics: CalculatedHealthMetrics?
    
    /// Loading state indicator
    /// Set to true when API calls are in progress
    @Published var isLoading = false
    
    /// Error message string to display to the user
    /// Contains user-friendly error descriptions
    @Published var errorMessage: String?
    
    /// Flag indicating whether an error alert should be shown
    /// Used to trigger alert dialogs in the View
    @Published var showError = false
    
    // MARK: - Private Properties
    
    /// Shared API service instance for making HTTP requests
    /// Handles authentication, request/response serialization, and error handling
    private let apiService = APIService.shared
    
    // MARK: - Public Methods
    
    /// Fetch the latest health metrics entry with all calculations
    ///
    /// Calls GET /health-metrics/latest endpoint to retrieve the most recent
    /// health metrics entry for the authenticated user. This includes all
    /// raw measurements and all calculated metrics (BMI, TDEE, RMR, ratios, etc.).
    ///
    /// Updates `latestMetrics` and `isLoading` published properties.
    /// Handles errors and updates error state if request fails.
    func fetchLatest() async {
        // Set loading state and clear previous errors
        isLoading = true
        errorMessage = nil
        showError = false
        
        do {
            // Make authenticated GET request to latest endpoint
            let response: HealthMetrics = try await apiService.request(
                endpoint: "/health-metrics/latest",
                method: .get,
                requiresAuth: true
            )
            
            // Update published property with response (triggers UI update)
            latestMetrics = response
            isLoading = false
        } catch let error as NetworkError {
            // Handle specific network errors
            handleError(error)
        } catch {
            // Handle unexpected errors
            handleError(.invalidResponse)
        }
    }
    
    /// Fetch only the calculated metrics (simplified response)
    ///
    /// Calls GET /health-metrics/calculations endpoint which returns only
    /// the calculated values (BMI, TDEE, RMR, categories) without all the
    /// raw measurements. Useful for quick lookups.
    ///
    /// Updates `calculatedMetrics` and `isLoading` published properties.
    /// Handles errors and updates error state if request fails.
    func fetchCalculatedOnly() async {
        // Set loading state and clear previous errors
        isLoading = true
        errorMessage = nil
        showError = false
        
        do {
            // Make authenticated GET request to calculations endpoint
            let response: CalculatedHealthMetrics = try await apiService.request(
                endpoint: "/health-metrics/calculations",
                method: .get,
                requiresAuth: true
            )
            
            // Update published property with response
            calculatedMetrics = response
            isLoading = false
        } catch let error as NetworkError {
            // Handle specific network errors
            handleError(error)
        } catch {
            // Handle unexpected errors
            handleError(.invalidResponse)
        }
    }
    
    /// Create a new health metrics entry
    ///
    /// Calls POST /health-metrics endpoint to create a new health metrics entry.
    /// The backend will calculate all derived metrics (BMI, TDEE, RMR, ratios, etc.)
    /// based on the input data and user profile information.
    ///
    /// - Parameter dto: The CreateHealthMetricsDto containing input data
    /// - Throws: NetworkError if the request fails
    ///
    /// Updates `latestMetrics` with the created entry (includes all calculations).
    /// Updates loading and error state accordingly.
    func createMetrics(_ dto: CreateHealthMetricsDto) async throws {
        // Set loading state and clear previous errors
        isLoading = true
        errorMessage = nil
        showError = false
        
        do {
            // Make authenticated POST request with DTO body
            let response: HealthMetrics = try await apiService.request(
                endpoint: "/health-metrics",
                method: .post,
                body: dto,
                requiresAuth: true
            )
            
            // Update latest metrics with the newly created entry
            // This includes all backend calculations
            latestMetrics = response
            isLoading = false
        } catch let error as NetworkError {
            // Reset loading state before throwing
            isLoading = false
            handleError(error)
            // Re-throw error so caller can handle it if needed
            throw error
        } catch {
            // Reset loading state before throwing
            isLoading = false
            handleError(.invalidResponse)
            throw error
        }
    }
    
    /// Refresh health metrics data
    ///
    /// Convenience method that calls fetchLatest() to refresh the data.
    /// Used by pull-to-refresh gestures in the View.
    func refreshMetrics() async {
        await fetchLatest()
    }
    
    // MARK: - Private Methods
    
    /// Handle network errors and update error state
    ///
    /// Converts NetworkError types into user-friendly error messages
    /// and updates the published error properties to trigger UI alerts.
    ///
    /// - Parameter error: The NetworkError that occurred
    private func handleError(_ error: NetworkError) {
        isLoading = false
        errorMessage = error.localizedDescription
        showError = true
        
        // Provide specific, user-friendly messages for common error types
        switch error {
        case .unauthorized:
            // Token expired or invalid - user needs to log in again
            errorMessage = "Your session has expired. Please log in again."
        case .rateLimited:
            // Too many requests - API rate limit exceeded
            errorMessage = "Too many requests. Please try again in a moment."
        case .noConnection:
            // No internet connection available
            errorMessage = "No internet connection. Please check your network."
        default:
            // Use the default error description for other errors
            errorMessage = error.localizedDescription
        }
    }
}

