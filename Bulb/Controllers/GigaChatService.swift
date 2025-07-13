import Foundation

class GigaChatService {
    private let clientId = "f47f8ce9-08f2-4481-ae98-3bffe247bb57"
    private let authKey = "ZjQ3ZjhjZTktMDhmMi00NDgxLWFlOTgtM2JmZmUyNDdiYjU3OmRhMWI2YTU3LTk4ZmYtNGNhYi1iOGNhLWE3MTVjMjFkOGIyZQ=="
    private let baseURL = "https://gigachat.devices.sberbank.ru/api/v1/chat/completions"
    // Обновленный URL для получения токена согласно документации
    private let tokenURL = "https://ngw.devices.sberbank.ru:9443/api/v2/oauth"
    
    private var accessToken: String?
    private var tokenExpirationDate: Date?
    
    func generateQuestion(category: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Сначала получаем токен если нужно
        getAccessToken { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let token):
                self.sendQuestionRequest(token: token, category: category, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func getAccessToken(completion: @escaping (Result<String, Error>) -> Void) {
        // Проверяем, есть ли уже действующий токен
        if let token = accessToken, let expirationDate = tokenExpirationDate, expirationDate > Date() {
            completion(.success(token))
            return
        }
        
        // Используем URL из документации
        var request = URLRequest(url: URL(string: tokenURL)!)
        request.httpMethod = "POST"
        request.addValue("Basic \(authKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Генерируем UUID для RqUID
        let uuid = UUID().uuidString
        request.addValue(uuid, forHTTPHeaderField: "RqUID")
        
        // Формируем тело запроса как urlencoded
        let bodyString = "scope=GIGACHAT_API_PERS"
        request.httpBody = bodyString.data(using: .utf8)
        
        // Создаем сессию с делегатом, который будет обходить проблемы с SSL
        let sessionDelegate = CustomURLSessionDelegate()
        let session = URLSession(configuration: .default, delegate: sessionDelegate, delegateQueue: nil)
        
        session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "GigaChatService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let token = json["access_token"] as? String,
                   let expiresAt = json["expires_at"] as? TimeInterval {
                    
                    self.accessToken = token
                    // Преобразуем expiresAt из миллисекунд с 1970 года в дату
                    self.tokenExpirationDate = Date(timeIntervalSince1970: expiresAt / 1000.0)
                    
                    completion(.success(token))
                } else {
                    completion(.failure(NSError(domain: "GigaChatService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to parse token response"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func sendQuestionRequest(token: String, category: String, completion: @escaping (Result<String, Error>) -> Void) {
        let prompt = "Создай интересный вопрос для игры 'Правда или действие' в категории \(category). Ответ должен содержать только текст вопроса, без дополнительных пояснений."
        
        let requestBody: [String: Any] = [
            "model": "GigaChat",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 100,
            "stream": false,
            "repetition_penalty": 1
        ]
        
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        // Используем ту же сессию с обходом SSL
        let sessionDelegate = CustomURLSessionDelegate()
        let session = URLSession(configuration: .default, delegate: sessionDelegate, delegateQueue: nil)
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "GigaChatService", code: 3, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    let cleanedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
                    completion(.success(cleanedContent))
                } else {
                    completion(.failure(NSError(domain: "GigaChatService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// Класс для обхода проверки SSL сертификатов
class CustomURLSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // ВНИМАНИЕ: Принимаем любые сертификаты (небезопасно для production!)
        if let serverTrust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
