import UIKit



// Кастомный класс для рисования стрелки
class ArrowView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        
        // Параметры стрелки
        let width: CGFloat = rect.width
        let height: CGFloat = rect.height
        let arrowHeadWidth: CGFloat = 30
        let arrowHeadHeight: CGFloat = 40
        let shaftWidth: CGFloat = 10
        
        // Начало в центре левой стороны (основание стрелки)
        path.move(to: CGPoint(x: 0, y: height / 2))
        
        // Линия вала стрелки
        path.addLine(to: CGPoint(x: width - arrowHeadWidth, y: height / 2))
        
        // Наконечник стрелки (треугольник)
        path.addLine(to: CGPoint(x: width - arrowHeadWidth, y: height / 2 - arrowHeadHeight / 2))
        path.addLine(to: CGPoint(x: width, y: height / 2))
        path.addLine(to: CGPoint(x: width - arrowHeadWidth, y: height / 2 + arrowHeadHeight / 2))
        path.addLine(to: CGPoint(x: width - arrowHeadWidth, y: height / 2))
        
        path.close()
        
        // Настройки заливки и обводки
        UIColor.white.setFill()
        path.fill()
        UIColor.black.setStroke()
        path.lineWidth = 2
        path.stroke()
        
        // Добавляем тень
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.3
    }
}

class ArrowGameViewController: UIViewController {
    // MARK: - Properties
    private var arrowView: ArrowView!
    private var isSpinning = false
    private var spinDuration: TimeInterval {
        return TimeInterval.random(in: 3.0...6.5) // Случайное время от 3 до 6.5 секунд
    }
    private let segmentsPerRotation: CGFloat = 12 // Количество "тиков" на один оборот
    
    // MARK: - UI Components
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "84C500")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Тапни, чтобы крутить стрелку!"
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
        arrowView = ArrowView()
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(arrowView)
        
        // Центрируем стрелку
        NSLayoutConstraint.activate([
            arrowView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            arrowView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            arrowView.widthAnchor.constraint(equalToConstant: 150),
            arrowView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Устанавливаем точку вращения в центре стрелки
        arrowView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: view)
        
        // Игнорируем касания на кнопке "Назад"
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
        
        // Генерируем случайное количество оборотов (5–6) и конечный угол
        let numberOfRotations = CGFloat.random(in: 5...6)
        let finalAngle = numberOfRotations * 2 * CGFloat.pi // Используем CGFloat.pi
        let duration = spinDuration
        
        // Рассчитываем угловую "шаговую" величину для имитации делений
        let totalSegments = numberOfRotations * segmentsPerRotation
        let anglePerSegment = (2 * CGFloat.pi) / segmentsPerRotation // Используем CGFloat.pi
        
        // Разбиваем анимацию на ключевые кадры
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [], animations: {
            // Фаза 1: Быстрое вращение (60% времени, 80% пути)
            let fastPhaseDuration = 0.6
            let fastAngle = finalAngle * 0.8 // Пройдем 80% пути на высокой скорости
            var currentAngle: CGFloat = 0
            
            // Разбиваем быструю фазу на шаги, чтобы гарантировать вращение по часовой стрелке
            let stepsInFastPhase = Int((fastAngle / (2 * CGFloat.pi)).rounded()) // Используем CGFloat.pi
            let stepAngle = (2 * CGFloat.pi) // Используем CGFloat.pi
            let stepDuration = fastPhaseDuration / Double(stepsInFastPhase)
            
            for i in 0..<stepsInFastPhase {
                currentAngle += stepAngle
                let startTime = Double(i) * stepDuration
                UIView.addKeyframe(withRelativeStartTime: startTime, relativeDuration: stepDuration) {
                    self.arrowView.transform = CGAffineTransform(rotationAngle: currentAngle)
                }
            }
            
            // Добавляем остаток быстрой фазы, чтобы достичь fastAngle
            let remainingFastAngle = fastAngle - currentAngle
            if remainingFastAngle > 0 {
                currentAngle += remainingFastAngle
                UIView.addKeyframe(withRelativeStartTime: fastPhaseDuration - stepDuration, relativeDuration: stepDuration) {
                    self.arrowView.transform = CGAffineTransform(rotationAngle: currentAngle)
                }
            }
            
            // Фаза 2: Замедление с "тиками" (40% времени, 20% пути)
            let slowPhaseDuration = 0.4
            let remainingAngle = finalAngle - currentAngle
            let remainingSegments = Int((remainingAngle / anglePerSegment).rounded())
            
            // Разбиваем оставшееся вращение на шаги (тиканье)
            let segmentDuration = slowPhaseDuration / Double(remainingSegments)
            
            for i in 0..<remainingSegments {
                currentAngle += anglePerSegment
                let startTime = fastPhaseDuration + (Double(i) * segmentDuration)
                UIView.addKeyframe(withRelativeStartTime: startTime, relativeDuration: segmentDuration) {
                    self.arrowView.transform = CGAffineTransform(rotationAngle: currentAngle)
                }
            }
        }, completion: { _ in
            self.isSpinning = false
            self.instructionLabel.text = "Тапни, чтобы крутить стрелку!"
        })
    }
    
    // MARK: - Utility Methods
    @objc private func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
}
