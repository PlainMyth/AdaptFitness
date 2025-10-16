//
//  KeychainManager.swift
//  AdaptFitness
//
//  Created by OzzieC8 on 10/16/25.
//

import Foundation
import Security

/// Manager for securely storing and retrieving sensitive data in the iOS Keychain
class KeychainManager {
    
    // MARK: - Singleton
    
    static let shared = KeychainManager()
    
    private init() {}
    
    // MARK: - Keys
    
    enum KeychainKey: String {
        case accessToken = "com.adaptfitness.accessToken"
        case refreshToken = "com.adaptfitness.refreshToken"
        case userEmail = "com.adaptfitness.userEmail"
    }
    
    // MARK: - Public Methods
    
    /// Save a string value to the Keychain
    /// - Parameters:
    ///   - value: The string value to save
    ///   - key: The key to associate with the value
    /// - Throws: KeychainError if the save operation fails
    func save(_ value: String, forKey key: KeychainKey) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.invalidData
        }
        
        // Delete any existing value first
        try? delete(forKey: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status: status)
        }
    }
    
    /// Load a string value from the Keychain
    /// - Parameter key: The key associated with the value
    /// - Returns: The string value if found, nil otherwise
    func load(forKey key: KeychainKey) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return string
    }
    
    /// Delete a value from the Keychain
    /// - Parameter key: The key associated with the value to delete
    /// - Throws: KeychainError if the delete operation fails
    func delete(forKey key: KeychainKey) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        // Success or item not found are both acceptable
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status: status)
        }
    }
    
    /// Delete all AdaptFitness data from the Keychain
    func deleteAll() throws {
        try delete(forKey: .accessToken)
        try delete(forKey: .refreshToken)
        try delete(forKey: .userEmail)
    }
    
    /// Check if a value exists in the Keychain
    /// - Parameter key: The key to check
    /// - Returns: true if the value exists, false otherwise
    func exists(forKey key: KeychainKey) -> Bool {
        return load(forKey: key) != nil
    }
}

// MARK: - Keychain Error

enum KeychainError: Error, LocalizedError {
    case invalidData
    case saveFailed(status: OSStatus)
    case deleteFailed(status: OSStatus)
    
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid data format"
        case .saveFailed(let status):
            return "Failed to save to Keychain (status: \(status))"
        case .deleteFailed(let status):
            return "Failed to delete from Keychain (status: \(status))"
        }
    }
}

// MARK: - Convenience Extensions

extension KeychainManager {
    
    /// Save access token
    func saveAccessToken(_ token: String) throws {
        try save(token, forKey: .accessToken)
    }
    
    /// Load access token
    func loadAccessToken() -> String? {
        return load(forKey: .accessToken)
    }
    
    /// Delete access token
    func deleteAccessToken() throws {
        try delete(forKey: .accessToken)
    }
    
    /// Save refresh token
    func saveRefreshToken(_ token: String) throws {
        try save(token, forKey: .refreshToken)
    }
    
    /// Load refresh token
    func loadRefreshToken() -> String? {
        return load(forKey: .refreshToken)
    }
    
    /// Delete refresh token
    func deleteRefreshToken() throws {
        try delete(forKey: .refreshToken)
    }
    
    /// Save user email
    func saveUserEmail(_ email: String) throws {
        try save(email, forKey: .userEmail)
    }
    
    /// Load user email
    func loadUserEmail() -> String? {
        return load(forKey: .userEmail)
    }
    
    /// Delete user email
    func deleteUserEmail() throws {
        try delete(forKey: .userEmail)
    }
}

