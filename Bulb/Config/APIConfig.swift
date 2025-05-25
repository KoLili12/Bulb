//
//  APIConfig.swift
//  Bulb
//
//  API Configuration for Railway deployment
//

import Foundation

struct APIConfig {
    static let shared = APIConfig()
    
    private init() {}
    
    // Railway production URL
    #if DEBUG
    static let baseURL = "http://localhost:8080" // Для локальной разработки
    #else
    static let baseURL = "https://bulb-server-production.up.railway.app" // Для production
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
        return baseURL + apiVersion + endpoint
    }
    
    // Простая функция для тестирования подключения
    static func testConnection(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: pingURL) else {
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: url) { _, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse {
                    completion(httpResponse.statusCode == 200)
                } else {
                    completion(false)
                }
            }
        }.resume()
    }
}
