//
//  APIModels.swift
//  Bulb
//
//  Fixed API response models with proper imports and declarations
//

import Foundation
import UIKit

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

// MARK: - Enhanced CardType enum for UI (moved before usage)
enum CardType: String, CaseIterable {
    case truth = "truth"
    case dare = "dare"
    
    var displayName: String {
        switch self {
        case .truth:
            return "Правда"
        case .dare:
            return "Действие"
        }
    }
    
    var color: UIColor {
        switch self {
        case .truth:
            return UIColor(hex: "84C500") // Green
        case .dare:
            return UIColor(hex: "5800CF") // Purple
        }
    }
    
    var icon: String {
        switch self {
        case .truth:
            return "questionmark.text.page.fill"
        case .dare:
            return "figure.american.football"
        }
    }
    
    var emoji: String {
        switch self {
        case .truth:
            return "👤"
        case .dare:
            return "🎯"
        }
    }
}

// MARK: - Enhanced Action Models with Type Support
struct Action: Codable {
    let id: UInt
    let text: String
    let type: String // "truth" or "dare"
    let order: Int
    
    // Computed properties for UI
    var actionType: CardType {
        return type == "dare" ? .dare : .truth
    }
    
    var displayText: String {
        return text
    }
    
    var typeIcon: String {
        return type == "dare" ? "🎯" : "👤"
    }
}

// MARK: - Collection Models with Actions Support
struct Collection: Codable {
    let id: UInt
    let name: String
    let description: String
    let imageUrl: String?
    let userId: UInt
    let playCount: Int
    let actions: [Action]?
    let createdAt: String
    
    // MARK: - Computed Properties for Card Statistics
    var totalCardsCount: Int {
        return actions?.count ?? 0
    }
    
    var truthCardsCount: Int {
        return actions?.filter { $0.type == "truth" }.count ?? 0
    }
    
    var dareCardsCount: Int {
        return actions?.filter { $0.type == "dare" }.count ?? 0
    }
    
    // Formatted card count string
    var formattedCardCount: String {
        let count = totalCardsCount
        switch count {
        case 1:
            return "\(count) карточка"
        case 2...4:
            return "\(count) карточки"
        default:
            return "\(count) карточек"
        }
    }
    
    // Card type breakdown string
    var cardTypeBreakdown: String {
        if truthCardsCount > 0 && dareCardsCount > 0 {
            return "👤 \(truthCardsCount) • 🎯 \(dareCardsCount)"
        } else if truthCardsCount > 0 {
            return "👤 \(truthCardsCount) правда"
        } else if dareCardsCount > 0 {
            return "🎯 \(dareCardsCount) действие"
        } else {
            return "Нет карточек"
        }
    }
}

struct CollectionRequest: Codable {
    let name: String
    let description: String
    let imageUrl: String?
}

struct ActionRequest: Codable {
    let text: String
    let type: String // "truth" or "dare"
    let order: Int
}

// MARK: - Collection Statistics
struct CollectionStats: Codable {
    let totalActions: Int
    let truthCount: Int
    let dareCount: Int
    
    var formattedStats: String {
        return "Всего: \(totalActions) • Правда: \(truthCount) • Действие: \(dareCount)"
    }
}

// MARK: - Enhanced Request Models for Creating Collections with Actions
struct CreateCollectionWithActionsRequest: Codable {
    let name: String
    let description: String
    let imageUrl: String?
    let actions: [CreateActionRequest]
}

struct CreateActionRequest: Codable {
    let text: String
    let type: String // "truth" or "dare"
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

struct ErrorResponse: Codable {
    let error: String
}

struct SuccessResponse: Codable {
    let message: String
}

// MARK: - Public User Response (for getting other users info)
struct PublicUserResponse: Codable {
    let id: UInt
    let name: String
    let surname: String
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

// MARK: - Location Tag enum for AddViewController
enum LocationTag: String, CaseIterable {
    case home = "Дома"
    case street = "Улица"
    
    var icon: String {
        switch self {
        case .home:
            return "house.fill"
        case .street:
            return "road.lanes"
        }
    }
}

// MARK: - GameCard compatibility for local UI models
struct GameCard {
    let id = UUID()
    let text: String
    let type: CardType
    
    // Convert to API format
    var apiAction: CreateActionRequest {
        return CreateActionRequest(
            text: text,
            type: type.rawValue,
            order: 0 // Will be set by service
        )
    }
}
