//
//  AuthDebugViewController.swift
//  Bulb
//
//  Simple debug screen for auth issues
//

import UIKit

class AuthDebugViewController: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "🔍 Auth Debug"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🔄 Обновить статус", for: .normal)
        button.backgroundColor = UIColor(hex: "84C500")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(refreshStatus), for: .touchUpInside)
        return button
    }()
    
    private lazy var testCreateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🧪 Тест создания коллекции", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(testCreateCollection), for: .touchUpInside)
        return button
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("❌ Закрыть", for: .normal)
        button.backgroundColor = UIColor.systemGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeDebug), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        refreshStatus()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(statusLabel)
        view.addSubview(refreshButton)
        view.addSubview(testCreateButton)
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            refreshButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 30),
            refreshButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            refreshButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            refreshButton.heightAnchor.constraint(equalToConstant: 50),
            
            testCreateButton.topAnchor.constraint(equalTo: refreshButton.bottomAnchor, constant: 16),
            testCreateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            testCreateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            testCreateButton.heightAnchor.constraint(equalToConstant: 50),
            
            closeButton.topAnchor.constraint(equalTo: testCreateButton.bottomAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func refreshStatus() {
        var status = ""
        
        // Проверяем авторизацию
        status += "🔐 Авторизация: \(AuthManager.shared.isLoggedIn ? "✅ Да" : "❌ Нет")\n\n"
        
        // Проверяем токен
        if let token = AuthManager.shared.accessToken {
            status += "🎫 Токен: \(String(token.prefix(30)))...\n\n"
        } else {
            status += "🎫 Токен: ❌ Отсутствует\n\n"
        }
        
        // Проверяем срок действия
        if let expiresAt = AuthManager.shared.expiresAt {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            status += "⏰ Истекает: \(formatter.string(from: expiresAt))\n"
            status += "⏰ Истек: \(AuthManager.shared.isTokenExpired ? "❌ Да" : "✅ Нет")\n\n"
        } else {
            status += "⏰ Срок действия: ❌ Неизвестен\n\n"
        }
        
        // Проверяем пользователя
        if let user = UserService.shared.getCurrentUserFromStorage() {
            status += "👤 Пользователь: \(user.name) \(user.surname)\n"
            status += "📧 Email: \(user.email)\n\n"
        } else {
            status += "👤 Пользователь: ❌ Не найден\n\n"
        }
        
        // Проверяем UserDefaults
        let keys = ["user_name", "user_surname", "user_email", "access_token"]
        status += "💾 UserDefaults:\n"
        for key in keys {
            let value = UserDefaults.standard.string(forKey: key)
            status += "\(key): \(value ?? "nil")\n"
        }
        
        statusLabel.text = status
    }
    
    @objc private func testCreateCollection() {
        print("🧪 Testing collection creation...")
        
        CollectionsService.shared.createCollection(
            name: "Тестовая коллекция \(Int.random(in: 1000...9999))",
            description: "Тестовое описание",
            imageUrl: nil
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.showAlert(title: "✅ Успех", message: "Коллекция создана: \(response.message)")
                case .failure(let error):
                    self.showAlert(title: "❌ Ошибка", message: "Не удалось создать: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func closeDebug() {
        dismiss(animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
