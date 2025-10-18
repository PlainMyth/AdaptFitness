//
//  AuthManager.swift
//  AdaptFitness
//
//  Manages user authentication and JWT token storage
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let tokenKey = "jwt_token"
    private let userIdKey = "user_id"
    private let keychain = KeychainManager.shared
    
    private init() {
        // Check if user is already logged in on app start
        loadSavedSession()
    }
    
    // MARK: - Authentication Methods
    
    func register(email: String, password: String, firstName: String, lastName: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        struct RegisterRequest: Encodable {
            let email: String
            let password: String
            let firstName: String
            let lastName: String
        }
        
        struct RegisterResponse: Decodable {
            let message: String
            let user: UserResponse
        }
        
        struct UserResponse: Decodable {
            let id: String
            let email: String
            let firstName: String
            let lastName: String
        }
        
        do {
            let _: RegisterResponse = try await APIService.shared.request(
                endpoint: "/auth/register",
                method: .post,
                body: RegisterRequest(
                    email: email,
                    password: password,
                    firstName: firstName,
                    lastName: lastName
                ),
                requiresAuth: false
            )
            
            // After successful registration, automatically log in
            try await login(email: email, password: password)
            
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func login(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        struct LoginRequest: Encodable {
            let email: String
            let password: String
        }
        
        struct LoginResponse: Decodable {
            let access_token: String
            let user: UserResponse
        }
        
        struct UserResponse: Decodable {
            let id: String
            let email: String
            let firstName: String
            let lastName: String
            let fullName: String?
            let isActive: Bool?
        }
        
        do {
            let response: LoginResponse = try await APIService.shared.request(
                endpoint: "/auth/login",
                method: .post,
                body: LoginRequest(email: email, password: password),
                requiresAuth: false
            )
            
            // Store JWT token securely in Keychain
            try? keychain.saveAccessToken(response.access_token)
            UserDefaults.standard.set(response.user.id, forKey: userIdKey)
            
            // Create User object from response
            currentUser = User(
                id: response.user.id,
                email: response.user.email,
                firstName: response.user.firstName,
                lastName: response.user.lastName,
                loginStreak: nil // Will be fetched from workouts
            )
            
            isAuthenticated = true
            
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func logout() {
        // Clear stored data from both Keychain and UserDefaults
        try? keychain.deleteAccessToken()
        try? keychain.deleteRefreshToken()
        UserDefaults.standard.removeObject(forKey: userIdKey)
        
        // Reset state
        currentUser = nil
        isAuthenticated = false
        errorMessage = nil
    }
    
    func loadSavedSession() {
        // Check if we have a stored token in Keychain
        if let _ = keychain.loadAccessToken(),
           let _ = UserDefaults.standard.string(forKey: userIdKey) {
            isAuthenticated = true
            
            // Try to load user profile from backend
            Task {
                await loadUserProfile()
            }
        }
    }
    
    func loadUserProfile() async {
        struct ProfileResponse: Decodable {
            let id: String
            let email: String
            let firstName: String
            let lastName: String
            let fullName: String?
            let isActive: Bool?
        }
        
        do {
            let profile: ProfileResponse = try await APIService.shared.request(
                endpoint: "/auth/profile",
                method: .get,
                requiresAuth: true
            )
            
            currentUser = User(
                id: profile.id,
                email: profile.email,
                firstName: profile.firstName,
                lastName: profile.lastName,
                loginStreak: nil
            )
            
        } catch {
            // Token might be expired
            logout()
        }
    }
    
    // Validate if user is logged in
    func requireAuthentication() -> Bool {
        return isAuthenticated && keychain.loadAccessToken() != nil
    }
    
    // Get current access token for API requests
    func getAccessToken() -> String? {
        return keychain.loadAccessToken()
    }
}

