//
//  User.swift
//  AdaptFitness
//
//  Created by csuftitan on 10/13/25.
//
import SwiftUI

struct User: Codable, Identifiable {
    var id: String
    var email: String
    var token: String?
    var lastLogin: Date?
    var loginStreak: Int?
}

extension User {
    static let exampleUser = User(
        id: UUID().uuidString,
        email: "user@example.com",
        token: "abc123",
        lastLogin: Date(),
        loginStreak: 5
    )
}
