//
//  AuthManager.swift
//  AdaptFitness
//
//  Created by AI Assistant
//

import Foundation
import SwiftUI

@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var authToken: String?
    
    private let userDefaults = UserDefaults.standard
    private let tokenKey = "auth_token"
    private let userKey = "current_user"
    
    init() {
        loadStoredAuth()
    }
    
    func login(email: String, password: String) async {
        do {
            let response = try await APIService.shared.login(email: email, password: password)
            await setAuthData(user: response.user, token: response.accessToken)
        } catch {
            print("Login failed: \(error)")
            // Handle login error
        }
    }
    
    func register(user: RegisterRequest) async {
        do {
            let response = try await APIService.shared.register(user: user)
            await setAuthData(user: response.user, token: response.accessToken)
        } catch {
            print("Registration failed: \(error)")
            // Handle registration error
        }
    }
    
    func logout() {
        isAuthenticated = false
        currentUser = nil
        authToken = nil
        userDefaults.removeObject(forKey: tokenKey)
        userDefaults.removeObject(forKey: userKey)
    }
    
    private func setAuthData(user: User, token: String) async {
        currentUser = user
        authToken = token
        isAuthenticated = true
        
        // Store in UserDefaults
        userDefaults.set(token, forKey: tokenKey)
        if let userData = try? JSONEncoder().encode(user) {
            userDefaults.set(userData, forKey: userKey)
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
