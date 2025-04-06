//
//  InitialViewController.swift
//  Bulb
//

import UIKit

class InitialViewController: UIViewController {
    
    // MARK: - UI Components
    
    private lazy var animatedLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont(name: "ArialMT", size: 130) ?? UIFont.systemFont(ofSize: 130, weight: .regular)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Properties
    
    private let fullText = "balb"
    private var currentIndex = 0
    private var timer: Timer?
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Устанавливаем фон тем же цветом, что и на экране запуска
        if let launchScreenColor = UIColor(named: "LaunchScreenBackground") {
            view.backgroundColor = launchScreenColor
        } else {
            // Запасной вариант, если цвет не найден в ассетах
            view.backgroundColor = UIColor(red: 0.52, green: 0.77, blue: 0, alpha: 1.0)
        }
        
        // Добавляем и позиционируем метку
        view.addSubview(animatedLabel)
        NSLayoutConstraint.activate([
            animatedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animatedLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            animatedLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animatedLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Запускаем анимацию печатания
        startTypingAnimation()
    }
    
    // MARK: - Animation Methods
    
    private func startTypingAnimation() {
        // Создаем таймер, который будет добавлять по одной букве каждые 0.3 секунды
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(animateText), userInfo: nil, repeats: true)
    }
    
    @objc private func animateText() {
        if currentIndex < fullText.count {
            // Добавляем следующую букву
            let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
            animatedLabel.text = String(fullText[...index])
            currentIndex += 1
        } else {
            // Когда все буквы добавлены, останавливаем таймер
            timer?.invalidate()
            
            // Добавляем небольшую паузу перед переходом к основному приложению
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.navigateToMainApp()
            }
        }
    }
    
    private func navigateToMainApp() {
        // Создаем и переходим к основному экрану приложения (TabBarViewController)
        let tabBarVC = TabBarViewController()
        tabBarVC.modalPresentationStyle = .fullScreen
        tabBarVC.modalTransitionStyle = .crossDissolve
        present(tabBarVC, animated: true)
    }
}
