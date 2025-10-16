//
//  NetworkError.swift
//  AdaptFitness
//
//  Network error handling for API requests
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int, String?)
    case decodingError(Error)
    case encodingError(Error)
    case rateLimited
    case unauthorized
    case noConnection
    case serverError(String)
    case badRequest(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
            
        case .invalidResponse:
            return "Invalid response from server"
            
        case .httpError(let code, let message):
            if let message = message {
                return "HTTP Error \(code): \(message)"
            }
            return "HTTP Error: \(code)"
            
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
            
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
            
        case .rateLimited:
            return "Too many requests. Please try again later."
            
        case .unauthorized:
            return "Please log in again"
            
        case .noConnection:
            return "No internet connection"
            
        case .serverError(let message):
            return "Server error: \(message)"
            
        case .badRequest(let message):
            return "Bad request: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .rateLimited:
            return "Wait a minute and try again"
        case .unauthorized:
            return "Your session has expired. Please log in again."
        case .noConnection:
            return "Check your internet connection and try again"
        default:
            return nil
        }
    }
}

