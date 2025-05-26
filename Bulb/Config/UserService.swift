//
//  UserService.swift
//  Bulb
//
//  Service for handling user profile operations
//

import Foundation

class UserService {
    static let shared = UserService()
    
    private init() {}
    
    // MARK: - User Profile Methods
    
    func getCurrentUser(completion: @escaping (Result<User, NetworkError>) -> Void) {
        // Поскольку в бэкенде нет эндпоинта /me, получим информацию из токена
        // Или создадим эндпоинт для получения текущего пользователя
        NetworkManager.shared.request(
            endpoint: "/user/me", // Этот эндпоинт нужно добавить в бэкенд
            method: .GET,
            responseType: User.self,
            requiresAuth: true
        ) { result in
            completion(result)
        }
    }
    
    func updateProfile(name: String, surname: String, email: String, phone: String?, description: String?, completion: @escaping (Result<User, NetworkError>) -> Void) {
        let request = UserUpdateRequest(
            name: name,
            surname: surname,
            email: email,
            phone: phone,
            description: description
        )
        
        NetworkManager.shared.request(
            endpoint: "/user/profile", // Этот эндпоинт тоже нужно добавить
            method: .PUT,
            body: request,
            responseType: User.self,
            requiresAuth: true
        ) { result in
            completion(result)
        }
    }
    
    // MARK: - Collections от пользователя
    
    func getUserCollections(completion: @escaping (Result<[Collection], NetworkError>) -> Void) {
        CollectionsService.shared.getUserCollections(completion: completion)
    }
}

// MARK: - Временное решение без новых эндпоинтов
extension UserService {
    
    // Создаем пользователя из токена JWT (временно)
    func getCurrentUserFromToken() -> User? {
        guard let token = AuthManager.shared.accessToken else { return nil }
        
        // В реальном приложении здесь был бы парсинг JWT токена
        // Пока возвращаем пример данных
        return User(
            id: 1,
            name: "Текущий",
            surname: "Пользователь",
            email: "user@example.com",
            phone: "+7 (999) 123-45-67",
            imageUrl: nil,
            description: "Описание пользователя",
            createdAt: Date()
        )
    }
    
    // Имитация обновления профиля (сохраняем в UserDefaults)
    func updateProfileLocally(name: String, surname: String, email: String, phone: String?, description: String?) {
        print("💾 Saving user data locally:")
        print("Name: \(name)")
        print("Surname: \(surname)")
        print("Email: \(email)")
        print("Phone: \(phone ?? "nil")")
        print("Description: \(description ?? "nil")")
        
        UserDefaults.standard.set(name, forKey: "user_name")
        UserDefaults.standard.set(surname, forKey: "user_surname")
        UserDefaults.standard.set(email, forKey: "user_email")
        UserDefaults.standard.set(phone, forKey: "user_phone")
        UserDefaults.standard.set(description, forKey: "user_description")
        UserDefaults.standard.synchronize() // Принудительно сохраняем
    }
    
    func getCurrentUserFromStorage() -> User? {
        guard AuthManager.shared.isLoggedIn else {
            print("❌ User not logged in")
            return nil
        }
        
        let name = UserDefaults.standard.string(forKey: "user_name")
        let surname = UserDefaults.standard.string(forKey: "user_surname")
        let email = UserDefaults.standard.string(forKey: "user_email")
        let phone = UserDefaults.standard.string(forKey: "user_phone")
        let description = UserDefaults.standard.string(forKey: "user_description")
        
        print("📖 Loading user data from storage:")
        print("Name: \(name ?? "nil")")
        print("Surname: \(surname ?? "nil")")
        print("Email: \(email ?? "nil")")
        
        // Если нет сохраненных данных, возвращаем дефолтные
        guard let userName = name, let userSurname = surname, let userEmail = email else {
            print("⚠️ No saved user data found, returning default user")
            return User(
                id: 1,
                name: "Пользователь",
                surname: "",
                email: "user@example.com",
                phone: nil,
                imageUrl: nil,
                description: "Добро пожаловать!",
                createdAt: Date()
            )
        }
        
        return User(
            id: 1,
            name: userName,
            surname: userSurname,
            email: userEmail,
            phone: phone?.isEmpty == true ? nil : phone,
            imageUrl: nil,
            description: description?.isEmpty == true ? nil : description,
            createdAt: Date()
        )
    }
}
