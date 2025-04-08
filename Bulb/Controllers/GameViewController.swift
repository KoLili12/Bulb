import UIKit

class GameViewController: UIViewController {
    // MARK: - Properties
    private var fingerViews: [UITouch: UIView] = [:]
    private let maxFingers = 8
    private var countdownTimer: Timer?
    private var remainingTime = 5
    
    // MARK: - UI Components
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "violetBulb") ?? .green
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var touchAreaView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear // Прозрачная зона для касаний
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isMultipleTouchEnabled = true
        return view
    }()
    
    private lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Положите пальцы на экран (макс. 8)"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var countdownLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Назад", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .red.withAlphaComponent(0.7)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    deinit {
        countdownTimer?.invalidate()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.addSubview(backgroundView)
        view.addSubview(touchAreaView)
        view.addSubview(instructionLabel)
        view.addSubview(countdownLabel)
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            touchAreaView.topAnchor.constraint(equalTo: view.topAnchor),
            touchAreaView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            touchAreaView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            touchAreaView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            instructionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            countdownLabel.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 20),
            countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 80),
            backButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touches began: \(touches.count)") // Отладка количества касаний
        
        for touch in touches {
            let location = touch.location(in: touchAreaView)
            
            // Игнорируем касания только в зоне backButton
            if backButton.frame.contains(touch.location(in: view)) {
                print("Touch ignored: \(location) - in backButton")
                continue
            }
            
            // Проверяем лимит пальцев
            guard fingerViews.count < maxFingers else {
                print("Max fingers reached: \(fingerViews.count)")
                break
            }
            
            // Создаем и добавляем круг
            let fingerView = createFingerView()
            fingerView.center = location
            touchAreaView.addSubview(fingerView)
            fingerViews[touch] = fingerView
            
            // Анимация появления
            fingerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(withDuration: 0.3) {
                fingerView.transform = .identity
            }
            
            print("Added finger at: \(location)") // Отладка
        }
        
        updateFingerCount()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let fingerView = fingerViews[touch] {
                let location = touch.location(in: touchAreaView)
                fingerView.center = location
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let fingerView = fingerViews[touch] {
                UIView.animate(withDuration: 0.3, animations: {
                    fingerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    fingerView.alpha = 0
                }) { _ in
                    fingerView.removeFromSuperview()
                }
                fingerViews.removeValue(forKey: touch)
            }
        }
        
        updateFingerCount()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    // MARK: - Finger View Management
    private func createFingerView() -> UIView {
        let fingerView = UIView()
        fingerView.backgroundColor = .white
        fingerView.layer.cornerRadius = 50
        fingerView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        fingerView.layer.shadowColor = UIColor.black.cgColor
        fingerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        fingerView.layer.shadowRadius = 4
        fingerView.layer.shadowOpacity = 0.3
        return fingerView
    }
    
    // MARK: - Utility Methods
    private func updateFingerCount() {
        instructionLabel.text = "Пальцев: \(fingerViews.count)"
        
        if fingerViews.count >= 3 {
            startCountdown()
        } else {
            countdownTimer?.invalidate()
            countdownLabel.isHidden = true
        }
    }
    
    @objc private func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Countdown and Selection
    private func startCountdown() {
        countdownTimer?.invalidate()
        
        remainingTime = 5
        countdownLabel.isHidden = false
        updateCountdownLabel()
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.remainingTime -= 1
            self.updateCountdownLabel()
            
            if self.remainingTime <= 0 {
                timer.invalidate()
                self.selectRandomFinger()
            }
        }
    }
    
    private func updateCountdownLabel() {
        countdownLabel.text = "Выбор через: \(remainingTime)"
    }
    
    private func selectRandomFinger() {
        guard fingerViews.count >= 3 else {
            instructionLabel.text = "Нужно минимум 3 пальца!"
            return
        }
        
        countdownLabel.isHidden = true
        countdownTimer?.invalidate()
        
        let allFingers = Array(fingerViews.values)
        let selectedFinger = allFingers.randomElement()
        
        animateSelection(selectedFinger: selectedFinger)
    }
    
    private func animateSelection(selectedFinger: UIView?) {
        UIView.animate(withDuration: 0.5) {
            for fingerView in self.fingerViews.values {
                if fingerView == selectedFinger {
                    fingerView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                    fingerView.backgroundColor = UIColor(named: "violetBulb") ?? .green
                } else {
                    fingerView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                    fingerView.backgroundColor = .gray
                }
            }
        }
    }
}
