//
//  APIService.swift
//  AdaptFitness
//
//  Core networking service for backend API communication
//

import Foundation

class APIService {
    static let shared = APIService()
    
    // Production URL - Change to localhost for local testing
    private let baseURL: String = {
        #if DEBUG
        // For testing with local backend
        // return "http://localhost:3000"
        
        // For testing with production backend (recommended during development)
        return "https://adaptfitness-production.up.railway.app"
        #else
        // Production
        return "https://adaptfitness-production.up.railway.app"
        #endif
    }()
    
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: configuration)
    }
    
    // Generic request method
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add JWT token if required
        if requiresAuth {
            guard let token = getStoredToken() else {
                throw NetworkError.unauthorized
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add request body if present
        if let body = body {
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                request.httpBody = try encoder.encode(body)
            } catch {
                throw NetworkError.encodingError(error)
            }
        }
        
        // Make the request
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // Handle different HTTP status codes
        switch httpResponse.statusCode {
        case 200...299:
            // Success - decode the response
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }
            
        case 400:
            // Bad Request - try to extract error message
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.badRequest(errorResponse.message)
            }
            throw NetworkError.httpError(400, "Bad Request")
            
        case 401:
            // Unauthorized - token expired or invalid
            throw NetworkError.unauthorized
            
        case 429:
            // Rate limited
            throw NetworkError.rateLimited
            
        case 500...599:
            // Server error
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.serverError(errorResponse.message)
            }
            throw NetworkError.httpError(httpResponse.statusCode, "Server Error")
            
        default:
            throw NetworkError.httpError(httpResponse.statusCode, nil)
        }
    }
    
    // Helper method to get stored JWT token from Keychain
    private func getStoredToken() -> String? {
        return KeychainManager.shared.loadAccessToken()
    }
}

// MARK: - HTTP Method Enum

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// MARK: - Error Response Model

struct ErrorResponse: Decodable {
    let message: String
    let error: String?
    let statusCode: Int?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle both single string and array of strings for message
        if let singleMessage = try? container.decode(String.self, forKey: .message) {
            self.message = singleMessage
        } else if let messageArray = try? container.decode([String].self, forKey: .message) {
            self.message = messageArray.joined(separator: ", ")
        } else {
            self.message = "Unknown error"
        }
        
        self.error = try? container.decode(String.self, forKey: .error)
        self.statusCode = try? container.decode(Int.self, forKey: .statusCode)
    }
    
    private enum CodingKeys: String, CodingKey {
        case message, error, statusCode
    }
}

