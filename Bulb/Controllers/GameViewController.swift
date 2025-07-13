import UIKit

class GameViewController: UIViewController {
    // MARK: - Properties
    private var fingerViews: [UITouch: UIView] = [:]
    private let maxFingers = 5
    private var countdownTimer: Timer?
    private var remainingTime = 3
    private var selectedTruthOrDareModes: Set<TruthOrDareMode> = []
    
    // Новые свойства для навигации по вопросам
    private var currentQuestionIndex = 0
    private var questions: [String] = []
    private var currentQuestionType: TruthOrDareMode = .truth
    private var isQuestionVisible = true
    
    // Constraint для анимации контента вопроса
    private var questionContentTopConstraint: NSLayoutConstraint!
    
    // Новые свойства для улучшенной визуализации
    private var isCountdownActive = false
    private var pulseAnimationTimer: Timer?
    
    // MARK: - 🎯 НОВЫЕ СВОЙСТВА ДЛЯ СИСТЕМЫ ОЦЕНКИ
    private var hasShownRatingPopup = false // Чтобы показать только один раз за сессию
    private var totalQuestionsCount: Int {
        return questions.count
    }
    
    private var progressPercentage: Float {
        guard totalQuestionsCount > 0 else { return 0 }
        return Float(currentQuestionIndex + 1) / Float(totalQuestionsCount)
    }
    
    // MARK: - UI Components
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "84C500")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var touchAreaView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isMultipleTouchEnabled = true
        return view
    }()
    
    // Статичная белая шапка
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.setTitle(" Выйти", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .black
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var questionTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var questionCounterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Контейнер для контента вопроса (который будет скрываться)
    private lazy var questionContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var questionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var progressBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        view.layer.cornerRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var progressFill: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var navigationButtons: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var previousButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        button.setImage(UIImage(systemName: "arrow.left", withConfiguration: config), for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(previousQuestion), for: .touchUpInside)
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        button.setImage(UIImage(systemName: "arrow.right", withConfiguration: config), for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(nextQuestion), for: .touchUpInside)
        return button
    }()
    
    // Полоска для показа возможности свайпа
    private lazy var pullIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.layer.cornerRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 1.0 // Всегда видна
        return view
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUIForSelectedModes()
        setupSwipeGestures()
        
        // Включаем множественные касания для всего view
        view.isMultipleTouchEnabled = true
        touchAreaView.isMultipleTouchEnabled = true
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.addSubview(backgroundView)
        view.addSubview(touchAreaView)
        view.addSubview(questionContentView)
        view.addSubview(headerView)
        
        // Элементы в статичной шапке
        headerView.addSubview(backButton)
        headerView.addSubview(questionTypeLabel)
        headerView.addSubview(questionCounterLabel)
        
        // Элементы в контенте вопроса
        questionContentView.addSubview(questionLabel)
        questionContentView.addSubview(progressBar)
        progressBar.addSubview(progressFill)
        questionContentView.addSubview(pullIndicator)
        questionContentView.addSubview(navigationButtons)
        
        navigationButtons.addArrangedSubview(previousButton)
        navigationButtons.addArrangedSubview(nextButton)
        
        questionContentTopConstraint = questionContentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            touchAreaView.topAnchor.constraint(equalTo: view.topAnchor),
            touchAreaView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            touchAreaView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            touchAreaView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            
            backButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -18),
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            
            questionTypeLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -18),
            questionTypeLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            questionTypeLabel.widthAnchor.constraint(equalToConstant: 80),
            questionTypeLabel.heightAnchor.constraint(equalToConstant: 24),
            
            questionCounterLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -18),
            questionCounterLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            questionContentTopConstraint,
            questionContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            questionContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            questionContentView.heightAnchor.constraint(equalToConstant: 200),
            
            questionLabel.topAnchor.constraint(equalTo: questionContentView.topAnchor, constant: 30),
            questionLabel.leadingAnchor.constraint(equalTo: questionContentView.leadingAnchor, constant: 16),
            questionLabel.trailingAnchor.constraint(equalTo: questionContentView.trailingAnchor, constant: -16),
            
            progressBar.leadingAnchor.constraint(equalTo: questionContentView.leadingAnchor, constant: 16),
            progressBar.trailingAnchor.constraint(equalTo: questionContentView.trailingAnchor, constant: -16),
            progressBar.bottomAnchor.constraint(equalTo: navigationButtons.topAnchor, constant: -16),
            progressBar.heightAnchor.constraint(equalToConstant: 4),
            
            progressFill.topAnchor.constraint(equalTo: progressBar.topAnchor),
            progressFill.leadingAnchor.constraint(equalTo: progressBar.leadingAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressBar.bottomAnchor),
            progressFill.widthAnchor.constraint(equalTo: progressBar.widthAnchor, multiplier: 0.1),
            
            navigationButtons.leadingAnchor.constraint(equalTo: questionContentView.leadingAnchor),
            navigationButtons.trailingAnchor.constraint(equalTo: questionContentView.trailingAnchor),
            navigationButtons.bottomAnchor.constraint(equalTo: questionContentView.bottomAnchor),
            navigationButtons.heightAnchor.constraint(equalToConstant: 50),
            
            pullIndicator.centerXAnchor.constraint(equalTo: navigationButtons.centerXAnchor),
            pullIndicator.centerYAnchor.constraint(equalTo: navigationButtons.centerYAnchor),
            pullIndicator.widthAnchor.constraint(equalToConstant: 40),
            pullIndicator.heightAnchor.constraint(equalToConstant: 4)
        ])
    }
    
    private func setupSwipeGestures() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(hideQuestion))
        swipeUp.direction = .up
        questionContentView.addGestureRecognizer(swipeUp)
        
        let swipeDownOnPrevious = UISwipeGestureRecognizer(target: self, action: #selector(showQuestion))
        swipeDownOnPrevious.direction = .down
        previousButton.addGestureRecognizer(swipeDownOnPrevious)
        
        let swipeDownOnNext = UISwipeGestureRecognizer(target: self, action: #selector(showQuestion))
        swipeDownOnNext.direction = .down
        nextButton.addGestureRecognizer(swipeDownOnNext)
        
        let tapToShow = UITapGestureRecognizer(target: self, action: #selector(showQuestion))
        pullIndicator.addGestureRecognizer(tapToShow)
        pullIndicator.isUserInteractionEnabled = true
        
        let swipeDownOnButtons = UISwipeGestureRecognizer(target: self, action: #selector(showQuestion))
        swipeDownOnButtons.direction = .down
        navigationButtons.addGestureRecognizer(swipeDownOnButtons)
    }
    
    // MARK: - Game Mode Setup
    func setTruthOrDareModes(_ modes: Set<TruthOrDareMode>) {
        selectedTruthOrDareModes = modes
        generateQuestions()
        
        if isViewLoaded {
            updateUIForSelectedModes()
        }
    }
    
    private func generateQuestions() {
        questions = []
        
        if selectedTruthOrDareModes.contains(.truth) {
            questions += [
                "Самый воспросительный вопрос для самого честного ответа от которого все будут в шоке реально (но не факт)?",
                "О чем ты никогда не расскажешь родителям?",
                "Самая странная привычка, которая у тебя есть?",
                "За кем из присутствующих ты бы пошел на свидание?",
                "Самая большая ложь, которую ты говорил?",
                "Что тебя больше всего раздражает в людях?",
                "Самый стыдный поступок в детстве?",
                "О чем ты мечтаешь, но боишься признаться?",
                "Кого из знаменитостей ты считаешь переоцененным?",
                "Самое глупое, что ты делал ради любви?"
            ]
        }
        
        if selectedTruthOrDareModes.contains(.dare) {
            questions += [
                "Расскажи анекдот, стоя на одной ноге",
                "Позвони случайному контакту и скажи 'Я тебя люблю'",
                "Съешь что-то острое без воды",
                "Станцуй 30 секунд без музыки",
                "Изобрази любое животное в течение минуты",
                "Спой песню голосом противоположного пола",
                "Сделай селфи в смешной позе и отправь родителям",
                "Попытайся лизнуть свой локоть",
                "Говори только шепотом следующие 3 вопроса",
                "Сделай планку в течение 30 секунд"
            ]
        }
        
        questions.shuffle()
        if !questions.isEmpty {
            updateCurrentQuestionType()
        }
    }
    
    private func updateCurrentQuestionType() {
        guard currentQuestionIndex < questions.count else { return }
        
        let currentQuestion = questions[currentQuestionIndex]
        
        // Простая логика определения типа по содержанию
        let truthKeywords = ["самый", "самая", "кого", "что", "как", "почему", "когда", "где", "какой"]
        let isLikelyTruth = truthKeywords.contains { currentQuestion.lowercased().contains($0) }
        
        if selectedTruthOrDareModes.contains(.truth) && selectedTruthOrDareModes.contains(.dare) {
            currentQuestionType = isLikelyTruth ? .truth : .dare
        } else if selectedTruthOrDareModes.contains(.truth) {
            currentQuestionType = .truth
        } else {
            currentQuestionType = .dare
        }
        
        updateBackgroundColor()
    }
    
    private func updateUIForSelectedModes() {
        updateBackgroundColor()
        updateQuestionCard()
    }
    
    private func updateBackgroundColor() {
        let targetColor: UIColor
        
        switch currentQuestionType {
        case .truth:
            targetColor = UIColor(hex: "84C500") // Зеленый
        case .dare:
            targetColor = UIColor(hex: "5800CF") // Фиолетовый
        }
        
        UIView.animate(withDuration: 0.3) {
            self.backgroundView.backgroundColor = targetColor
        }
    }
    
    private var progressWidthConstraint: NSLayoutConstraint?
    
    private func updateQuestionCard() {
        guard !questions.isEmpty else { return }
        
        let currentQuestion = questions[currentQuestionIndex]
        questionLabel.text = currentQuestion
        questionCounterLabel.text = "\(currentQuestionIndex + 1)/\(questions.count)"
        
        questionTypeLabel.text = currentQuestionType.rawValue
        switch currentQuestionType {
        case .truth:
            questionTypeLabel.backgroundColor = UIColor(hex: "84C500")
        case .dare:
            questionTypeLabel.backgroundColor = UIColor(hex: "5800CF")
        }
        
        let progress = CGFloat(currentQuestionIndex + 1) / CGFloat(questions.count)
        progressWidthConstraint?.isActive = false
        progressWidthConstraint = progressFill.widthAnchor.constraint(equalTo: progressBar.widthAnchor, multiplier: progress)
        progressWidthConstraint?.isActive = true
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        previousButton.alpha = currentQuestionIndex > 0 ? 1.0 : 0.3
        nextButton.alpha = currentQuestionIndex < questions.count - 1 ? 1.0 : 0.3
    }
    
    // MARK: - Actions
    @objc private func hideQuestion() {
        guard isQuestionVisible else { return }
        
        isQuestionVisible = false
        
        questionContentTopConstraint.constant = -100
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc private func showQuestion() {
        guard !isQuestionVisible else { return }
        
        isQuestionVisible = true
        
        questionContentTopConstraint.constant = 40
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc private func previousQuestion() {
        guard currentQuestionIndex > 0 else { return }
        
        currentQuestionIndex -= 1
        updateCurrentQuestionType()
        updateQuestionCard()
        
        if !isQuestionVisible {
            showQuestion()
        }
    }
    
    @objc private func nextQuestion() {
        guard currentQuestionIndex < questions.count - 1 else { return }
        
        currentQuestionIndex += 1
        updateCurrentQuestionType()
        updateQuestionCard()
        
        if !isQuestionVisible {
            showQuestion()
        }
    }
    
    @objc private func dismissViewController() {
        // 🎯 ПРОВЕРЯЕМ ПРОГРЕСС ПЕРЕД ВЫХОДОМ
        checkProgressAndShowRatingIfNeeded { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - 🎯 СИСТЕМА ОЦЕНКИ ПОДБОРКИ
    
    private func checkProgressAndShowRatingIfNeeded(completion: @escaping () -> Void) {
        // Проверяем: прошел ли пользователь 25% или больше И не показывали ли уже popup
        if progressPercentage >= 0.25 && !hasShownRatingPopup {
            showRatingPopup(completion: completion)
        } else {
            completion()
        }
    }
    
    private func showRatingPopup(completion: @escaping () -> Void) {
        hasShownRatingPopup = true
        
        let ratingPopup = RatingPopupViewController()
        ratingPopup.delegate = self
        ratingPopup.modalPresentationStyle = .overFullScreen
        ratingPopup.modalTransitionStyle = .crossDissolve
        
        // Сохраняем completion для использования в delegate методах
        objc_setAssociatedObject(ratingPopup, "completion", completion, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        
        present(ratingPopup, animated: false)
    }
    
    // MARK: - 🎯 ИСПРАВЛЕННАЯ ОБРАБОТКА КАСАНИЙ
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touches began: \(touches.count)")
        
        for touch in touches {
            let location = touch.location(in: touchAreaView)
            
            // Исключаем касания в области шапки и контента вопроса
            if headerView.frame.contains(touch.location(in: view)) ||
               questionContentView.frame.contains(touch.location(in: view)) {
                continue
            }
            
            if fingerViews[touch] != nil {
                continue
            }
            
            if fingerViews.count >= maxFingers {
                continue
            }
            
            let fingerView = createFingerView()
            fingerView.center = location
            touchAreaView.addSubview(fingerView)
            fingerViews[touch] = fingerView
            
            fingerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(withDuration: 0.3) {
                fingerView.transform = .identity
            }
            
            // 🎯 ЛЕГКАЯ ВИБРАЦИЯ ПРИ ДОБАВЛЕНИИ НОВОГО ПАЛЬЦА
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
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
                // Останавливаем пульсацию если палец убран
                stopPulseAnimation(for: fingerView)
                
                // 🎯 ИСПРАВЛЕНИЕ: Проверяем, является ли палец выбранным
                let isSelectedFinger = fingerView.transform.a > 1.2 // Проверяем, увеличен ли палец
                
                if isSelectedFinger {
                    // 🎯 КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: Убираем ВСЕ анимации сначала
                    fingerView.layer.removeAllAnimations()
                    
                    // Мгновенно сбрасываем к обычному виду БЕЗ анимации
                    fingerView.transform = .identity
                    fingerView.backgroundColor = .white
                    fingerView.layer.borderWidth = 3
                    fingerView.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
                    fingerView.layer.shadowOffset = CGSize(width: 0, height: 4)
                    fingerView.layer.shadowRadius = 8
                    fingerView.layer.shadowOpacity = 0.3
                    
                    // ТЕПЕРЬ анимируем уменьшение от нормального размера
                    UIView.animate(withDuration: 0.25, animations: {
                        fingerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                        fingerView.alpha = 0
                    }) { _ in
                        fingerView.removeFromSuperview()
                    }
                } else {
                    // Для обычных пальцев: стандартная анимация
                    UIView.animate(withDuration: 0.3, animations: {
                        fingerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                        fingerView.alpha = 0
                    }) { _ in
                        fingerView.removeFromSuperview()
                    }
                }
                
                fingerViews.removeValue(forKey: touch)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updateFingerCount()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let fingerView = fingerViews[touch] {
                stopPulseAnimation(for: fingerView)
                
                // 🎯 ИСПРАВЛЕНИЕ: Такая же логика для отмененных касаний
                let isSelectedFinger = fingerView.transform.a > 1.2
                
                if isSelectedFinger {
                    // 🎯 КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: Убираем ВСЕ анимации сначала
                    fingerView.layer.removeAllAnimations()
                    
                    // Мгновенно сбрасываем к обычному виду БЕЗ анимации
                    fingerView.transform = .identity
                    fingerView.backgroundColor = .white
                    fingerView.layer.borderWidth = 3
                    fingerView.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
                    fingerView.layer.shadowOffset = CGSize(width: 0, height: 4)
                    fingerView.layer.shadowRadius = 8
                    fingerView.layer.shadowOpacity = 0.3
                    
                    // ТЕПЕРЬ анимируем уменьшение от нормального размера
                    UIView.animate(withDuration: 0.25, animations: {
                        fingerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                        fingerView.alpha = 0
                    }) { _ in
                        fingerView.removeFromSuperview()
                    }
                } else {
                    UIView.animate(withDuration: 0.3, animations: {
                        fingerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                        fingerView.alpha = 0
                    }) { _ in
                        fingerView.removeFromSuperview()
                    }
                }
                
                fingerViews.removeValue(forKey: touch)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updateFingerCount()
        }
    }
    
    // MARK: - 🎯 УЛУЧШЕННОЕ СОЗДАНИЕ FINGER VIEW с контрастным цветом
    private func createFingerView() -> UIView {
        let fingerView = UIView()
        
        let fingerColor: UIColor
        
        // Используем контрастный цвет относительно фона
        switch currentQuestionType {
        case .truth:
            // Фон зеленый -> используем белый для пальцев
            fingerColor = .white
        case .dare:
            // Фон фиолетовый -> используем белый для пальцев
            fingerColor = .white
        }
        
        fingerView.backgroundColor = fingerColor
        fingerView.layer.cornerRadius = 50
        fingerView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        // Добавляем тень для лучшей видимости
        fingerView.layer.shadowColor = UIColor.black.cgColor
        fingerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        fingerView.layer.shadowRadius = 8
        fingerView.layer.shadowOpacity = 0.3
        
        // Добавляем границу для еще лучшей видимости
        fingerView.layer.borderWidth = 3
        fingerView.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
        
        return fingerView
    }
    
    // MARK: - 🎯 НОВЫЕ МЕТОДЫ ДЛЯ ПУЛЬСАЦИИ
    private func startPulseAnimation(for fingerView: UIView) {
        // Останавливаем предыдущую анимацию если есть
        fingerView.layer.removeAllAnimations()
        
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 0.5
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.2
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        
        fingerView.layer.add(pulseAnimation, forKey: "pulseAnimation")
    }
    
    private func stopPulseAnimation(for fingerView: UIView) {
        fingerView.layer.removeAnimation(forKey: "pulseAnimation")
        
        // Возвращаем к нормальному размеру только если это НЕ выбранный палец
        if fingerView.transform.a <= 1.2 {
            UIView.animate(withDuration: 0.2) {
                fingerView.transform = .identity
            }
        }
    }
    
    private func startPulseAnimationForAllFingers() {
        for fingerView in fingerViews.values {
            startPulseAnimation(for: fingerView)
        }
        
        // 🎯 ДОБАВЛЯЕМ ВИБРАЦИЮ ПРИ НАЧАЛЕ ПУЛЬСАЦИИ
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func stopPulseAnimationForAllFingers() {
        for fingerView in fingerViews.values {
            stopPulseAnimation(for: fingerView)
        }
    }
    
    // MARK: - 🎯 УЛУЧШЕННЫЙ COUNTDOWN с пульсацией
    private func updateFingerCount() {
        print("Update finger count: \(fingerViews.count)")
        
        let deadTouches = fingerViews.filter { $0.value.superview == nil }
        for (touch, _) in deadTouches {
            fingerViews.removeValue(forKey: touch)
        }
        
        if fingerViews.count >= 2 {
            startCountdown()
        } else {
            // Останавливаем countdown и пульсацию
            countdownTimer?.invalidate()
            countdownTimer = nil
            isCountdownActive = false
            stopPulseAnimationForAllFingers()
            
            // 🎯 НОВОЕ: Сбрасываем все пальцы к нормальному виду
            resetAllFingersToNormalState()
        }
    }
    
    // 🎯 НОВЫЙ МЕТОД: Сброс всех пальцев к обычному виду
    private func resetAllFingersToNormalState() {
        for fingerView in fingerViews.values {
            // 🎯 ИСПРАВЛЕНИЕ: Убираем все анимации ПЕРЕД изменением внешнего вида
            fingerView.layer.removeAllAnimations()
            
            // Проверяем, не в нормальном ли уже состоянии
            if fingerView.transform.a != 1.0 || fingerView.backgroundColor != UIColor.white {
                // Мгновенно сбрасываем цвет БЕЗ анимации для предотвращения всплесков
                fingerView.backgroundColor = .white
                fingerView.layer.borderWidth = 3
                fingerView.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
                fingerView.layer.shadowOffset = CGSize(width: 0, height: 4)
                fingerView.layer.shadowRadius = 8
                fingerView.layer.shadowOpacity = 0.3
                
                // Только размер анимируем плавно
                UIView.animate(withDuration: 0.2) {
                    fingerView.transform = .identity
                }
            }
        }
    }
    
    private func startCountdown() {
        // Останавливаем предыдущий таймер если он есть
        countdownTimer?.invalidate()
        countdownTimer = nil
        
        remainingTime = 3
        isCountdownActive = true
        print("Starting countdown with \(fingerViews.count) fingers")
        
        // 🎯 НАЧИНАЕМ ПУЛЬСАЦИЮ ВСЕХ ПАЛЬЦЕВ (с вибрацией)
        startPulseAnimationForAllFingers()
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.remainingTime -= 1
            print("Countdown: \(self.remainingTime), fingers: \(self.fingerViews.count)")
            
            // 🎯 ДОБАВЛЯЕМ ЛЕГКУЮ ВИБРАЦИЮ НА КАЖДЫЙ ТИК ТАЙМЕРА
            let selectionFeedback = UISelectionFeedbackGenerator()
            selectionFeedback.selectionChanged()
            
            if self.remainingTime <= 0 {
                timer.invalidate()
                self.countdownTimer = nil
                self.isCountdownActive = false
                self.selectRandomFinger()
            }
        }
    }
    
    private func selectRandomFinger() {
        print("Selecting random finger from \(fingerViews.count) fingers")
        
        guard fingerViews.count >= 2 else {
            stopPulseAnimationForAllFingers()
            return
        }
        
        let allFingers = Array(fingerViews.values)
        let selectedFinger = allFingers.randomElement()
        
        animateSelection(selectedFinger: selectedFinger)
    }
    
    // MARK: - 🎯 УЛУЧШЕННАЯ АНИМАЦИЯ СЕЛЕКЦИИ с контрастными цветами
    private func animateSelection(selectedFinger: UIView?) {
        // Сначала останавливаем все пульсации
        stopPulseAnimationForAllFingers()
        
        // 🎯 МОЩНАЯ ВИБРАЦИЯ ПРИ ВЫБОРЕ ПОБЕДИТЕЛЯ
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        UIView.animate(withDuration: 0.5, animations: {
            for fingerView in self.fingerViews.values {
                if fingerView == selectedFinger {
                    // 🎯 ВЫБРАННЫЙ ПАЛЕЦ - яркий контрастный цвет с увеличением
                    fingerView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                    
                    // Используем яркие контрастные цвета вместо цвета фона
                    let selectedColor: UIColor
                    switch self.currentQuestionType {
                    case .truth:
                        selectedColor = UIColor.systemYellow // Яркий желтый на зеленом фоне
                    case .dare:
                        selectedColor = UIColor.systemOrange // Яркий оранжевый на фиолетовом фоне
                    }
                    
                    fingerView.backgroundColor = selectedColor
                    
                    // Добавляем дополнительную границу для выделения
                    fingerView.layer.borderWidth = 5
                    fingerView.layer.borderColor = UIColor.white.cgColor
                    
                    // Добавляем более яркую тень
                    fingerView.layer.shadowColor = UIColor.black.cgColor
                    fingerView.layer.shadowOffset = CGSize(width: 0, height: 6)
                    fingerView.layer.shadowRadius = 12
                    fingerView.layer.shadowOpacity = 0.5
                    
                } else {
                    // Невыбранные пальцы становятся меньше и тусклее
                    fingerView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                    fingerView.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
                    fingerView.layer.borderColor = UIColor.gray.cgColor
                    fingerView.layer.borderWidth = 2
                }
            }
        }) { _ in
            // После анимации выбора добавляем пульсацию только к выбранному пальцу
            if let selected = selectedFinger {
                self.addWinnerPulseAnimation(to: selected)
            }
        }
    }
    
    // MARK: - 🎯 СПЕЦИАЛЬНАЯ АНИМАЦИЯ ДЛЯ ПОБЕДИТЕЛЯ
    private func addWinnerPulseAnimation(to fingerView: UIView) {
        // 🎯 ДОПОЛНИТЕЛЬНАЯ ВИБРАЦИЯ ДЛЯ ПОБЕДИТЕЛЯ
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
        }
        
        // Создаем специальную анимацию для победителя
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 0.8
        pulseAnimation.fromValue = 1.5  // Начинаем с увеличенного размера
        pulseAnimation.toValue = 1.7    // Пульсируем еще больше
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = 3  // Пульсирует 3 раза
        
        // Анимация свечения
        let glowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        glowAnimation.duration = 0.8
        glowAnimation.fromValue = 0.5
        glowAnimation.toValue = 0.8
        glowAnimation.autoreverses = true
        glowAnimation.repeatCount = 3
        
        fingerView.layer.add(pulseAnimation, forKey: "winnerPulse")
        fingerView.layer.add(glowAnimation, forKey: "winnerGlow")
    }
}

// MARK: - 🎯 ДЕЛЕГАТ СИСТЕМЫ ОЦЕНКИ
extension GameViewController: RatingPopupDelegate {
    func didSubmitRating(_ rating: Int) {
        print("🌟 User rated collection: \(rating) stars")
        
        // Здесь можно отправить оценку на сервер
        // API call to submit rating...
        
        // Получаем completion из associated object
        if let completion = objc_getAssociatedObject(self, "completion") as? () -> Void {
            completion()
        }
    }
    
    func didSkipRating() {
        print("⏭️ User skipped rating")
        
        // Получаем completion из associated object
        if let completion = objc_getAssociatedObject(self, "completion") as? () -> Void {
            completion()
        }
    }
    
    func didReturnToGame() {
        print("🎮 User returned to game")
        // Ничего не делаем - просто возвращаемся в игру
    }
}

