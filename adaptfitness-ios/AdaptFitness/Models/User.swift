//
//  User.swift
//  AdaptFitness
//
//  Created by csuftitan on 10/13/25.
//
import SwiftUI
import Combine

struct User: Codable, Identifiable {
    var id: String
    var email: String
    var firstName: String
    var lastName: String
    var token: String?
    var lastLogin: Date?
    var loginStreak: Int?
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
}

extension User {
    static let exampleUser = User(
        id: UUID().uuidString,
        email: "user@example.com",
        firstName: "John",
        lastName: "Doe",
        token: "abc123",
        lastLogin: Date(),
        loginStreak: 5
    )
}
