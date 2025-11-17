//
//  AuthModels.swift
//  AdaptFitness
//
//  Authentication-related data models
//

import Foundation

struct AuthResponse: Codable {
    let accessToken: String
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case user
    }
}

struct LoginRequest: Codable {
    let email: String
    let password: String
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

