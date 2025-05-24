import UIKit

class ArrowGameViewController: UIViewController {
    
    // MARK: - Properties
    private var isSpinning = false
    private var arrowView: UIImageView!
    
    // MARK: - UI Components
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "84C500")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Тапни, чтобы крутить"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
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
        setupArrow()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.addSubview(backgroundView)
        view.addSubview(instructionLabel)
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            instructionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 80),
            backButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupArrow() {
        // Используем UIImageView вместо кастомного ArrowView
        arrowView = UIImageView(image: UIImage(systemName: "arrow.right"))
        arrowView.tintColor = .white
        arrowView.contentMode = .scaleAspectFit
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(arrowView)
        
        NSLayoutConstraint.activate([
            arrowView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            arrowView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            arrowView.widthAnchor.constraint(equalToConstant: 150),
            arrowView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: view)
        
        // Игнорируем касания на кнопках
        if backButton.frame.contains(location) {
            return
        }
        
        // Запускаем вращение, если стрелка не крутится
        if !isSpinning {
            startSpinning()
        }
    }
    
    // MARK: - Arrow Spinning Logic
    private func startSpinning() {
        isSpinning = true
        instructionLabel.text = "Крутим..."
        
        // Упрощенная анимация вращения
        UIView.animate(withDuration: 3.0,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseOut,
                       animations: {
            // Случайный угол поворота (от 0 до 360 градусов)
            let randomAngle = CGFloat.random(in: 0...360) * .pi / 180
            self.arrowView.transform = CGAffineTransform(rotationAngle: randomAngle)
        }, completion: { _ in
            self.isSpinning = false
            self.instructionLabel.text = "Тапни, чтобы крутить"
        })
    }
    
    // MARK: - Utility Methods
    @objc private func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    // Метод для поддержки выбранных режимов Правда/Действие
    private var selectedTruthOrDareModes: Set<TruthOrDareMode> = []
    
    func setTruthOrDareModes(_ modes: Set<TruthOrDareMode>) {
        selectedTruthOrDareModes = modes
        
        if isViewLoaded {
            updateUIForSelectedModes()
        }
    }
    
    private func updateUIForSelectedModes() {
        var modeText = ""
        
        if selectedTruthOrDareModes.contains(.truth) {
            modeText += "Правда"
        }
        
        if selectedTruthOrDareModes.contains(.dare) {
            if !modeText.isEmpty {
                modeText += " и "
            }
            modeText += "Действие"
        }
        
        if !modeText.isEmpty {
            instructionLabel.text = "Режим: \(modeText)\nТапни, чтобы крутить"
        }
    }
}
