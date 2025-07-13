//
//  NetworkManager.swift
//  Bulb
//
//  Network layer for API communication
//

import Foundation

// MARK: - Network Manager
class NetworkManager {
    static let shared = NetworkManager()
    
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    private init() {
        // Настройка декодера для работы с датами
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
    }
    
    // MARK: - Generic Request Method
    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Codable? = nil,
        responseType: T.Type,
        requiresAuth: Bool = false,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard let url = URL(string: APIConfig.url(for: endpoint)) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Добавляем авторизацию если нужно
        if requiresAuth {
            if let token = AuthManager.shared.accessToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                completion(.failure(.unauthorized))
                return
            }
        }
        
        // Добавляем тело запроса если есть
        if let body = body {
            do {
                request.httpBody = try encoder.encode(body)
            } catch {
                completion(.failure(.encodingError))
                return
            }
        }
        
        // Выполняем запрос
        session.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.handleResponse(
                    data: data,
                    response: response,
                    error: error,
                    responseType: responseType,
                    completion: completion
                )
            }
        }.resume()
    }
    
    private func handleResponse<T: Codable>(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        if let error = error {
            completion(.failure(.networkError(error.localizedDescription)))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            completion(.failure(.invalidResponse))
            return
        }
        
        // Проверяем статус код
        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            completion(.failure(.unauthorized))
            return
        case 404:
            completion(.failure(.notFound))
            return
        case 400...499:
            completion(.failure(.clientError(httpResponse.statusCode)))
            return
        case 500...599:
            completion(.failure(.serverError(httpResponse.statusCode)))
            return
        default:
            completion(.failure(.unknownError))
            return
        }
        
        guard let data = data else {
            completion(.failure(.noData))
            return
        }
        
        // Декодируем ответ
        do {
            let result = try decoder.decode(responseType, from: data)
            completion(.success(result))
        } catch {
            print("Decoding error: \(error)")
            completion(.failure(.decodingError))
        }
    }
}

// MARK: - HTTP Methods
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

// MARK: - Network Errors (с Equatable!)
enum NetworkError: Error, LocalizedError, Equatable {
    case invalidURL
    case networkError(String)
    case invalidResponse
    case unauthorized
    case notFound
    case clientError(Int)
    case serverError(Int)
    case noData
    case encodingError
    case decodingError
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .networkError(let message):
            return "Ошибка сети: \(message)"
        case .invalidResponse:
            return "Неверный ответ сервера"
        case .unauthorized:
            return "Необходима авторизация"
        case .notFound:
            return "Ресурс не найден"
        case .clientError(let code):
            return "Ошибка клиента: \(code)"
        case .serverError(let code):
            return "Ошибка сервера: \(code)"
        case .noData:
            return "Нет данных"
        case .encodingError:
            return "Ошибка кодирования данных"
        case .decodingError:
            return "Ошибка декодирования данных"
        case .unknownError:
            return "Неизвестная ошибка"
        }
    }
    
    // MARK: - Equatable Conformance
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.unauthorized, .unauthorized),
             (.notFound, .notFound),
             (.noData, .noData),
             (.encodingError, .encodingError),
             (.decodingError, .decodingError),
             (.unknownError, .unknownError):
            return true
        case (.networkError(let lhsMessage), .networkError(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.clientError(let lhsCode), .clientError(let rhsCode)):
            return lhsCode == rhsCode
        case (.serverError(let lhsCode), .serverError(let rhsCode)):
            return lhsCode == rhsCode
        default:
            return false
        }
    }
}
