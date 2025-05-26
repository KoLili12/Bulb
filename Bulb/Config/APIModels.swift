//
//  APIModels.swift
//  Bulb
//
//  API response models matching backend DTOs
//

import Foundation

// MARK: - Auth Models
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let name: String
    let surname: String
    let email: String
    let password: String
    let phone: String?
}

struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
}

// MARK: - User Models
struct User: Codable {
    let id: UInt
    let name: String
    let surname: String
    let email: String
    let phone: String?
    let imageUrl: String?
    let description: String?
    let createdAt: Date
    
    // Custom init for convenience
    init(id: UInt, name: String, surname: String, email: String, phone: String? = nil, imageUrl: String? = nil, description: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.surname = surname
        self.email = email
        self.phone = phone
        self.imageUrl = imageUrl
        self.description = description
        self.createdAt = createdAt
    }
}

struct UserUpdateRequest: Codable {
    let name: String
    let surname: String
    let email: String
    let phone: String?
    let description: String?
}

struct UpdateProfileRequest: Codable {
    let name: String
    let surname: String
    let email: String
    let phone: String?
    let description: String?
}

// MARK: - Public User Response (for getting other users info)
struct PublicUserResponse: Codable {
    let id: UInt
    let name: String
    let surname: String
}

// MARK: - Collection Models
struct Collection: Codable {
    let id: UInt
    let name: String
    let description: String
    let imageUrl: String?
    let userId: UInt
    let playCount: Int
    let actions: [Action]?
    let createdAt: String // Используем String для простоты
}

struct CollectionRequest: Codable {
    let name: String
    let description: String
    let imageUrl: String?
}

// MARK: - Action Models
struct Action: Codable {
    let id: UInt
    let text: String
    let order: Int
}

struct ActionRequest: Codable {
    let text: String
    let order: Int
}

// MARK: - Response Models
struct CollectionsResponse: Codable {
    let items: [Collection]
}

struct PaginationResponse: Codable {
    let total: Int64
    let page: Int
    let size: Int
    let items: [Collection]
}

struct ActionsResponse: Codable {
    let items: [Action]
}

// MARK: - Error Response
struct ErrorResponse: Codable {
    let error: String
}

struct SuccessResponse: Codable {
    let message: String
}
