//
//  AuthModels.swift
//  FlashLang
//
//  Created by SARE OUMAROU on 30.07.25.
//

import Foundation

// MARK: - Authentication Models
struct AuthUser: Codable {
    let id: String
    let email: String
    let fullName: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct AuthResponse: Codable {
    let user: AuthUser?
    let session: Session?
    let error: AuthError?
    
    // Handle case where response is just a user object (when email confirmation is disabled)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode as a full AuthResponse first
        if let user = try? container.decodeIfPresent(AuthUser.self, forKey: .user),
           let session = try? container.decodeIfPresent(Session.self, forKey: .session) {
            self.user = user
            self.session = session
            self.error = try? container.decodeIfPresent(AuthError.self, forKey: .error)
        } else {
            // If that fails, try to decode as just a user object
            if let user = try? container.decode(AuthUser.self, forKey: .user) {
                self.user = user
            } else {
                self.user = try? AuthUser(from: decoder)
            }
            self.session = try? container.decodeIfPresent(Session.self, forKey: .session)
            self.error = try? container.decodeIfPresent(AuthError.self, forKey: .error)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case user
        case session
        case error
    }
}

struct Session: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}

struct AuthError: Codable, Error {
    let message: String
    let status: Int?
    let errorCode: String?
    
    enum CodingKeys: String, CodingKey {
        case message = "msg"
        case status = "code"
        case errorCode = "error_code"
    }
    
    var localizedDescription: String {
        return message
    }
}

// MARK: - Authentication State
enum AuthState {
    case loading
    case authenticated(AuthUser)
    case unauthenticated
    case error(String)
}

// MARK: - Login/Signup Models
struct LoginCredentials {
    let email: String
    let password: String
}

struct SignupCredentials {
    let email: String
    let fullName: String
    let password: String
    let confirmPassword: String
}

// MARK: - Validation Models
struct ValidationResult {
    let isValid: Bool
    let errorMessage: String?
}

// MARK: - User Profile
struct UserProfile: Codable {
    let id: String
    let email: String
    let username: String?
    let avatarUrl: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case username
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
} 