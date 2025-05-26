//
//  AuthManager.swift
//  Bulb
//
//  Authentication manager for handling user login/logout
//

import Foundation

class AuthManager {
    static let shared = AuthManager()
    
    private let userDefaults = UserDefaults.standard
    private let accessTokenKey = "access_token"
    private let refreshTokenKey = "refresh_token"
    private let expiresAtKey = "expires_at"
    
    private init() {}
    
    // MARK: - Properties
    var accessToken: String? {
        get { userDefaults.string(forKey: accessTokenKey) }
        set {
            if let token = newValue {
                userDefaults.set(token, forKey: accessTokenKey)
            } else {
                userDefaults.removeObject(forKey: accessTokenKey)
            }
        }
    }
    
    var refreshToken: String? {
        get { userDefaults.string(forKey: refreshTokenKey) }
        set {
            if let token = newValue {
                userDefaults.set(token, forKey: refreshTokenKey)
            } else {
                userDefaults.removeObject(forKey: refreshTokenKey)
            }
        }
    }
    
    var expiresAt: Date? {
        get {
            let timestamp = userDefaults.double(forKey: expiresAtKey)
            return timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
        }
        set {
            if let date = newValue {
                userDefaults.set(date.timeIntervalSince1970, forKey: expiresAtKey)
            } else {
                userDefaults.removeObject(forKey: expiresAtKey)
            }
        }
    }
    
    var isLoggedIn: Bool {
        let hasToken = accessToken != nil
        print("🔍 Auth check - Has token: \(hasToken)")
        if let token = accessToken {
            print("🎫 Token preview: \(String(token.prefix(20)))...")
        }
        return hasToken
    }
    
    var isTokenExpired: Bool {
        guard let expiresAt = expiresAt else { return true }
        return Date() >= expiresAt
    }
    
    // MARK: - Auth Methods
    func saveTokens(response: TokenResponse) {
        print("💾 Saving tokens...")
        accessToken = response.accessToken
        refreshToken = response.refreshToken
        expiresAt = response.expiresAt
        
        print("✅ Tokens saved successfully")
        print("🎫 Access token: \(String(response.accessToken.prefix(20)))...")
        print("⏰ Expires at: \(response.expiresAt)")
    }
    
    func clearTokens() {
        accessToken = nil
        refreshToken = nil
        expiresAt = nil
    }
    
    // MARK: - API Methods
    func login(email: String, password: String, completion: @escaping (Result<TokenResponse, NetworkError>) -> Void) {
        let request = LoginRequest(email: email, password: password)
        
        NetworkManager.shared.request(
            endpoint: "/auth/login",
            method: .POST,
            body: request,
            responseType: TokenResponse.self
        ) { [weak self] result in
            switch result {
            case .success(let tokenResponse):
                print("✅ Login successful, saving tokens")
                self?.saveTokens(response: tokenResponse)
                
                // Сохраняем email из логина
                UserService.shared.updateProfileLocally(
                    name: "Пользователь", // По умолчанию
                    surname: "",
                    email: email,
                    phone: nil,
                    description: nil
                )
                
                completion(.success(tokenResponse))
            case .failure(let error):
                print("❌ Login failed: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func register(name: String, surname: String, email: String, password: String, phone: String?, completion: @escaping (Result<TokenResponse, NetworkError>) -> Void) {
        let request = RegisterRequest(
            name: name,
            surname: surname,
            email: email,
            password: password,
            phone: phone
        )
        
        NetworkManager.shared.request(
            endpoint: "/auth/register",
            method: .POST,
            body: request,
            responseType: TokenResponse.self
        ) { [weak self] result in
            switch result {
            case .success(let tokenResponse):
                self?.saveTokens(response: tokenResponse)
                
                // Сохраняем данные пользователя локально после успешной регистрации
                UserService.shared.updateProfileLocally(
                    name: name,
                    surname: surname,
                    email: email,
                    phone: phone,
                    description: nil
                )
                
                completion(.success(tokenResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func refreshTokens(completion: @escaping (Result<TokenResponse, NetworkError>) -> Void) {
        guard let refreshToken = refreshToken else {
            completion(.failure(.unauthorized))
            return
        }
        
        let request = RefreshTokenRequest(refreshToken: refreshToken)
        
        NetworkManager.shared.request(
            endpoint: "/auth/refresh",
            method: .POST,
            body: request,
            responseType: TokenResponse.self
        ) { [weak self] result in
            switch result {
            case .success(let tokenResponse):
                self?.saveTokens(response: tokenResponse)
                completion(.success(tokenResponse))
            case .failure(let error):
                // Если refresh токен недействителен, очищаем все токены
                self?.clearTokens()
                completion(.failure(error))
            }
        }
    }
    
    func logout() {
        clearTokens()
        // Здесь можно добавить дополнительную логику logout
    }
}
