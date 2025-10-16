//
//  User.swift
//  AdaptFitness
//
//  Created by AI Assistant
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let dateOfBirth: String?
    let height: Double?
    let weight: Double?
    let gender: String?
    let activityLevel: String?
    let activityLevelMultiplier: Double?
    let isActive: Bool
    let createdAt: String
    let updatedAt: String
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
}

struct AuthResponse: Codable {
    let accessToken: String
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case user
    }
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let firstName: String
    let lastName: String
    let dateOfBirth: String?
    let height: Double?
    let weight: Double?
    let gender: String?
    let activityLevel: String?
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}
