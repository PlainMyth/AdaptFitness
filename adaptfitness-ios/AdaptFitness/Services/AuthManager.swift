//
//  AuthManager.swift
//  AdaptFitness
//
//  Created by AI Assistant
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var authToken: String?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAutoLoggingIn = false
    
    private let userDefaults = UserDefaults.standard
    private let keychainManager = KeychainManager.shared
    private let tokenKey = "auth_token"
    private let userKey = "current_user"
    private let rememberMeKey = "remember_me_enabled"
    
    private init() {
        loadStoredAuth()
        // Attempt auto-login if we have saved credentials but no valid session
        if !isAuthenticated {
            Task {
                await attemptAutoLogin()
            }
        }
    }
    
    /// Attempts to automatically log in using saved credentials
    /// Only called if Remember Me was enabled and credentials exist
    func attemptAutoLogin() async {
        guard let saved = getSavedCredentials() else {
            isAutoLoggingIn = false
            return
        }
        
        isAutoLoggingIn = true
        
        do {
            try await login(email: saved.email, password: saved.password, rememberMe: true)
            print("✅ Auto-login successful")
        } catch {
            // Auto-login failed, clear invalid credentials
            print("⚠️ Auto-login failed: \(error.localizedDescription)")
            clearSavedCredentials()
        }
        
        isAutoLoggingIn = false
    }
    
    func login(email: String, password: String, rememberMe: Bool = false) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await APIService.shared.login(email: email, password: password)
            await setAuthData(user: response.user, token: response.accessToken, rememberMe: rememberMe, email: email, password: password)
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func register(user: RegisterRequest, rememberMe: Bool = false) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await APIService.shared.register(user: user)
            await setAuthData(user: response.user, token: response.accessToken, rememberMe: rememberMe, email: user.email, password: user.password)
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func logout() {
        let shouldRememberMe = userDefaults.bool(forKey: rememberMeKey)
        
        isAuthenticated = false
        currentUser = nil
        authToken = nil
        userDefaults.removeObject(forKey: tokenKey)
        userDefaults.removeObject(forKey: userKey)
        
        // Clear saved credentials if Remember Me is disabled
        if !shouldRememberMe {
            clearSavedCredentials()
        }
    }
    
    /// Clear saved email and password from Keychain
    func clearSavedCredentials() {
        try? keychainManager.deletePassword()
        try? keychainManager.deleteUserEmail()
        userDefaults.set(false, forKey: rememberMeKey)
    }
    
    /// Get saved credentials if Remember Me is enabled
    func getSavedCredentials() -> (email: String, password: String)? {
        guard userDefaults.bool(forKey: rememberMeKey),
              let email = keychainManager.loadUserEmail(),
              let password = keychainManager.loadPassword() else {
            return nil
        }
        return (email: email, password: password)
    }
    
    /// Handles token expiration (401 errors) by clearing auth state
    /// This will automatically redirect the user to the login screen
    func handleTokenExpiration() {
        print("⚠️ Token expired or invalid. Logging out...")
        logout()
    }
    
    private func setAuthData(user: User, token: String, rememberMe: Bool = false, email: String? = nil, password: String? = nil) async {
        currentUser = user
        authToken = token
        isAuthenticated = true
        
        // Store in UserDefaults
        userDefaults.set(token, forKey: tokenKey)
        if let userData = try? JSONEncoder().encode(user) {
            userDefaults.set(userData, forKey: userKey)
        }
        
        // Save credentials if Remember Me is enabled
        if rememberMe, let email = email, let password = password {
            userDefaults.set(true, forKey: rememberMeKey)
            try? keychainManager.saveUserEmail(email)
            try? keychainManager.savePassword(password)
        } else {
            // Clear saved credentials if Remember Me is disabled
            clearSavedCredentials()
        }
    }
    
    private func loadStoredAuth() {
        if let token = userDefaults.string(forKey: tokenKey),
           let userData = userDefaults.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            authToken = token
            currentUser = user
            isAuthenticated = true
        }
    }
    
    var isLoggedIn: Bool {
        return isAuthenticated && authToken != nil && currentUser != nil
    }
}
