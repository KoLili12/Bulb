//
//  APIConfig.swift
//  Bulb
//
//  API Configuration with debugging
//

import Foundation

struct APIConfig {
    static let shared = APIConfig()
    
    private init() {}
    
    // ВАЖНО: Замените этот URL на ваш актуальный Railway URL
    #if DEBUG
    static let baseURL = "https://bulb-server-production.up.railway.app" // Используем Railway даже в DEBUG для тестирования
    #else
    static let baseURL = "https://bulb-server-production.up.railway.app" // Ваш Railway URL
    #endif
    
    static let apiVersion = "/api"
    
    // Endpoints
    struct Endpoints {
        static let auth = "/auth"
        static let collections = "/collections"
        static let users = "/users"
        static let ping = "/ping"
    }
    
    // Full URLs
    static var authURL: String { baseURL + apiVersion + Endpoints.auth }
    static var collectionsURL: String { baseURL + apiVersion + Endpoints.collections }
    static var usersURL: String { baseURL + apiVersion + Endpoints.users }
    static var pingURL: String { baseURL + Endpoints.ping }
    
    // Создание URL для конкретных запросов
    static func url(for endpoint: String) -> String {
        let fullURL = baseURL + apiVersion + endpoint
        print("🌐 Making request to: \(fullURL)") // Добавляем логирование
        return fullURL
    }
    
    // Простая функция для тестирования подключения
    static func testConnection(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: pingURL) else {
            print("❌ Invalid ping URL: \(pingURL)")
            completion(false)
            return
        }
        
        print("🔍 Testing connection to: \(pingURL)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Connection test failed: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Connection test response: \(httpResponse.statusCode)")
                    completion(httpResponse.statusCode == 200)
                } else {
                    print("❌ Invalid response type")
                    completion(false)
                }
            }
        }.resume()
    }
}
