//
//  UserService.swift
//  Bulb
//
//  Service for handling user profile operations with real API integration
//

import Foundation

class UserService {
    static let shared = UserService()
    
    private init() {}
    
    // MARK: - User Profile Methods
    
    func getCurrentUser(completion: @escaping (Result<User, NetworkError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: "/user/profile",
            method: .GET,
            responseType: User.self,
            requiresAuth: true
        ) { [weak self] result in
            switch result {
            case .success(let user):
                // Сохраняем данные локально для офлайн доступа
                self?.saveUserDataLocally(user)
                completion(.success(user))
            case .failure(let error):
                // При ошибке пытаемся загрузить из локального хранилища
                if let localUser = self?.getCurrentUserFromStorage() {
                    completion(.success(localUser))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func updateProfile(name: String, surname: String, email: String, phone: String?, description: String?, completion: @escaping (Result<SuccessResponse, NetworkError>) -> Void) {
        // Создаем структуру запроса напрямую
        struct ProfileUpdateRequest: Codable {
            let name: String
            let surname: String
            let email: String
            let phone: String?
            let description: String?
        }
        
        let request = ProfileUpdateRequest(
            name: name,
            surname: surname,
            email: email,
            phone: phone,
            description: description
        )
        
        NetworkManager.shared.request(
            endpoint: "/user/profile",
            method: .PUT,
            body: request,
            responseType: SuccessResponse.self,
            requiresAuth: true
        ) { [weak self] result in
            switch result {
            case .success(let response):
                // Обновляем локальные данные после успешного обновления
                self?.updateProfileLocally(
                    name: name,
                    surname: surname,
                    email: email,
                    phone: phone,
                    description: description
                )
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Collections от пользователя
    
    func getUserCollections(completion: @escaping (Result<[Collection], NetworkError>) -> Void) {
        CollectionsService.shared.getUserCollections(completion: completion)
    }
    
    // MARK: - Local Storage Methods
    
    private func saveUserDataLocally(_ user: User) {
        UserDefaults.standard.set(user.name, forKey: "user_name")
        UserDefaults.standard.set(user.surname, forKey: "user_surname")
        UserDefaults.standard.set(user.email, forKey: "user_email")
        UserDefaults.standard.set(user.phone, forKey: "user_phone")
        UserDefaults.standard.set(user.description, forKey: "user_description")
        UserDefaults.standard.set(user.id, forKey: "user_id")
        UserDefaults.standard.synchronize()
        
        print("💾 User data saved locally: \(user.name) \(user.surname)")
    }
    
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
        UserDefaults.standard.synchronize()
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
        let userId = UserDefaults.standard.object(forKey: "user_id") as? UInt ?? 1
        
        print("📖 Loading user data from storage:")
        print("Name: \(name ?? "nil")")
        print("Surname: \(surname ?? "nil")")
        print("Email: \(email ?? "nil")")
        
        // Если нет сохраненных данных, возвращаем дефолтные
        guard let userName = name, let userSurname = surname, let userEmail = email else {
            print("⚠️ No saved user data found, returning default user")
            return User(
                id: userId,
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
            id: userId,
            name: userName,
            surname: userSurname,
            email: userEmail,
            phone: phone?.isEmpty == true ? nil : phone,
            imageUrl: nil,
            description: description?.isEmpty == true ? nil : description,
            createdAt: Date()
        )
    }
    
    // MARK: - Public User Data (for displaying authors)
    
    func getUser(id: UInt, completion: @escaping (Result<User, NetworkError>) -> Void) {
        // Делаем реальный запрос к API
        NetworkManager.shared.request(
            endpoint: "/users/\(id)",
            method: .GET,
            responseType: PublicUserResponse.self,
            requiresAuth: false
        ) { result in
            switch result {
            case .success(let publicUser):
                // Конвертируем публичный ответ в полную модель User
                let user = User(
                    id: publicUser.id,
                    name: publicUser.name,
                    surname: publicUser.surname,
                    email: "hidden@example.com", // Скрываем email для публичного API
                    phone: nil,
                    imageUrl: nil,
                    description: nil,
                    createdAt: Date()
                )
                completion(.success(user))
                
            case .failure(let error):
                print("❌ Failed to load user \(id): \(error)")
                // Fallback к дефолтным данным при ошибке
                let fallbackUser = User(
                    id: id,
                    name: "Пользователь",
                    surname: "\(id)",
                    email: "user\(id)@example.com",
                    phone: nil,
                    imageUrl: nil,
                    description: nil,
                    createdAt: Date()
                )
                completion(.success(fallbackUser))
            }
        }
    }
}
