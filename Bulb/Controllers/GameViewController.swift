import UIKit

class GameViewController: UIViewController {
    // MARK: - Properties
    private var fingerViews: [UITouch: UIView] = [:]
    private let maxFingers = 5 // Ограничение iOS
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
    
    // Добавляем метод для установки выбранных режимов
    func setTruthOrDareModes(_ modes: Set<TruthOrDareMode>) {
        selectedTruthOrDareModes = modes
        generateQuestions()
        
        if isViewLoaded {
            updateUIForSelectedModes()
        }
    }
    
    // Генерируем вопросы для игры
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
    
    // Определяем тип текущего вопроса
    private func updateCurrentQuestionType() {
        guard currentQuestionIndex < questions.count else { return }
        
        let currentQuestion = questions[currentQuestionIndex]
        
        // Простая логика определения типа по содержанию
        let truthKeywords = ["самый", "самая", "кого", "что", "как", "почему", "когда", "где", "какой"]
        let isLikelyTruth = truthKeywords.contains { currentQuestion.lowercased().contains($0) }
        
        if selectedTruthOrDareModes.contains(.truth) && selectedTruthOrDareModes.contains(.dare) {
            // Если выбраны оба режима, определяем по ключевым словам
            currentQuestionType = isLikelyTruth ? .truth : .dare
        } else if selectedTruthOrDareModes.contains(.truth) {
            currentQuestionType = .truth
        } else {
            currentQuestionType = .dare
        }
        
        updateBackgroundColor()
    }
    
    // Метод для обновления UI в зависимости от выбранных режимов
    private func updateUIForSelectedModes() {
        updateBackgroundColor()
        updateQuestionCard()
    }
    
    // Обновляем цвет фона в зависимости от типа вопроса
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUIForSelectedModes()
        setupSwipeGestures()
        
        // Включаем множественные касания для всего view
        view.isMultipleTouchEnabled = true
        touchAreaView.isMultipleTouchEnabled = true
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
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.addSubview(backgroundView)
        view.addSubview(touchAreaView)
        view.addSubview(questionContentView)  // Добавляем СНАЧАЛА контент вопроса
        view.addSubview(headerView)           // ПОТОМ шапку (чтобы была поверх)
        
        // Элементы в статичной шапке
        headerView.addSubview(backButton)
        headerView.addSubview(questionTypeLabel)
        headerView.addSubview(questionCounterLabel)
        
        // Элементы в контенте вопроса
        questionContentView.addSubview(questionLabel)
        questionContentView.addSubview(progressBar)
        progressBar.addSubview(progressFill)
        questionContentView.addSubview(pullIndicator) // Полоску в контент вопроса
        questionContentView.addSubview(navigationButtons)
        
        navigationButtons.addArrangedSubview(previousButton)
        navigationButtons.addArrangedSubview(nextButton)
        
        // Основной constraint для позиции контента вопроса - начинаем ПОД шапкой
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
            
            // Статичная шапка - расширяем до верха экрана
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            
            // Элементы в шапке - привязываем к safeArea
            backButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -18),
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            
            questionTypeLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -18),
            questionTypeLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            questionTypeLabel.widthAnchor.constraint(equalToConstant: 80),
            questionTypeLabel.heightAnchor.constraint(equalToConstant: 24),
            
            questionCounterLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -18),
            questionCounterLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            // Контент вопроса
            questionContentTopConstraint,
            questionContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            questionContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            questionContentView.heightAnchor.constraint(equalToConstant: 200),
            
            // Элементы внутри контента вопроса
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
            
            // Полоска для свайпа - на том же уровне что и стрелки, снизу
            pullIndicator.centerXAnchor.constraint(equalTo: navigationButtons.centerXAnchor),
            pullIndicator.centerYAnchor.constraint(equalTo: navigationButtons.centerYAnchor),
            pullIndicator.widthAnchor.constraint(equalToConstant: 40),
            pullIndicator.heightAnchor.constraint(equalToConstant: 4)
        ])
    }
    
    private var progressWidthConstraint: NSLayoutConstraint?
    
    private func setupSwipeGestures() {
        // Свайп вверх для скрытия контента вопроса
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(hideQuestion))
        swipeUp.direction = .up
        questionContentView.addGestureRecognizer(swipeUp)
        
        // Свайп вниз для показа контента вопроса - добавляем на КНОПКИ навигации
        let swipeDownOnPrevious = UISwipeGestureRecognizer(target: self, action: #selector(showQuestion))
        swipeDownOnPrevious.direction = .down
        previousButton.addGestureRecognizer(swipeDownOnPrevious)
        
        let swipeDownOnNext = UISwipeGestureRecognizer(target: self, action: #selector(showQuestion))
        swipeDownOnNext.direction = .down
        nextButton.addGestureRecognizer(swipeDownOnNext)
        
        // Тап по полоске для показа контента
        let tapToShow = UITapGestureRecognizer(target: self, action: #selector(showQuestion))
        pullIndicator.addGestureRecognizer(tapToShow)
        pullIndicator.isUserInteractionEnabled = true
        
        // Также добавляем свайп вниз на сам navigationButtons
        let swipeDownOnButtons = UISwipeGestureRecognizer(target: self, action: #selector(showQuestion))
        swipeDownOnButtons.direction = .down
        navigationButtons.addGestureRecognizer(swipeDownOnButtons)
    }
    
    private func updateQuestionCard() {
        guard !questions.isEmpty else { return }
        
        let currentQuestion = questions[currentQuestionIndex]
        questionLabel.text = currentQuestion
        questionCounterLabel.text = "\(currentQuestionIndex + 1)/\(questions.count)"
        
        // Обновляем тип вопроса
        questionTypeLabel.text = currentQuestionType.rawValue
        switch currentQuestionType {
        case .truth:
            questionTypeLabel.backgroundColor = UIColor(hex: "84C500")
        case .dare:
            questionTypeLabel.backgroundColor = UIColor(hex: "5800CF")
        }
        
        // Обновляем прогресс-бар
        let progress = CGFloat(currentQuestionIndex + 1) / CGFloat(questions.count)
        progressWidthConstraint?.isActive = false
        progressWidthConstraint = progressFill.widthAnchor.constraint(equalTo: progressBar.widthAnchor, multiplier: progress)
        progressWidthConstraint?.isActive = true
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        // Обновляем доступность кнопок
        previousButton.alpha = currentQuestionIndex > 0 ? 1.0 : 0.3
        nextButton.alpha = currentQuestionIndex < questions.count - 1 ? 1.0 : 0.3
    }
    
    // MARK: - Actions
    @objc private func hideQuestion() {
        guard isQuestionVisible else { return }
        
        isQuestionVisible = false
        
        // Анимация скрытия контента вопроса - уходит ПОД шапку, но стрелки остаются видны
        questionContentTopConstraint.constant = -100 // Меньше смещение, чтобы стрелки были видны
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc private func showQuestion() {
        guard !isQuestionVisible else { return }
        
        isQuestionVisible = true
        
        // Анимация показа контента вопроса
        questionContentTopConstraint.constant = 40 // Возвращаем под шапку
        
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
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touches began: \(touches.count)")
        
        for touch in touches {
            let location = touch.location(in: touchAreaView)
            
            // Исключаем касания в области шапки и контента вопроса
            if headerView.frame.contains(touch.location(in: view)) ||
               questionContentView.frame.contains(touch.location(in: view)) {
                print("Touch ignored: \(location) - in header or question content")
                continue
            }
            
            // Проверяем, что touch еще не добавлен
            if fingerViews[touch] != nil {
                print("Touch already exists, skipping")
                continue
            }
            
            // Ограничиваем количество касаний до 5 (лимит iOS)
            if fingerViews.count >= maxFingers {
                print("Max fingers reached (\(maxFingers)), ignoring new touch")
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
            
            print("Added finger at: \(location), total fingers: \(self.fingerViews.count)")
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
        print("Touches ended: \(touches.count)")
        
        for touch in touches {
            if let fingerView = fingerViews[touch] {
                UIView.animate(withDuration: 0.3, animations: {
                    fingerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    fingerView.alpha = 0
                }) { _ in
                    fingerView.removeFromSuperview()
                }
                fingerViews.removeValue(forKey: touch)
                print("Removed finger, remaining: \(self.fingerViews.count)")
            }
        }
        
        // Добавляем небольшую задержку перед обновлением счетчика
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updateFingerCount()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touches cancelled: \(touches.count)")
        
        // При отмене касаний все равно удаляем их, но аккуратно
        for touch in touches {
            if let fingerView = fingerViews[touch] {
                UIView.animate(withDuration: 0.3, animations: {
                    fingerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    fingerView.alpha = 0
                }) { _ in
                    fingerView.removeFromSuperview()
                }
                fingerViews.removeValue(forKey: touch)
                print("Removed cancelled finger, remaining: \(self.fingerViews.count)")
            }
        }
        
        // Обновляем счетчик с задержкой
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updateFingerCount()
        }
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
        print("Update finger count: \(fingerViews.count)")
        
        // Очищаем "мертвые" касания (view без superview)
        let deadTouches = fingerViews.filter { $0.value.superview == nil }
        for (touch, _) in deadTouches {
            fingerViews.removeValue(forKey: touch)
            print("Removed dead touch, remaining: \(fingerViews.count)")
        }
        
        if fingerViews.count >= 2 {
            startCountdown()
        } else {
            countdownTimer?.invalidate()
            countdownTimer = nil
        }
    }
    
    private func startCountdown() {
        // Останавливаем предыдущий таймер если он есть
        countdownTimer?.invalidate()
        countdownTimer = nil
        
        remainingTime = 3
        print("Starting countdown with \(fingerViews.count) fingers")
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.remainingTime -= 1
            print("Countdown: \(self.remainingTime), fingers: \(self.fingerViews.count)")
            
            if self.remainingTime <= 0 {
                timer.invalidate()
                self.countdownTimer = nil
                self.selectRandomFinger()
            }
        }
    }
    
    private func selectRandomFinger() {
        print("Selecting random finger from \(fingerViews.count) fingers")
        
        guard fingerViews.count >= 2 else {
            print("Not enough fingers for selection")
            return
        }
        
        let allFingers = Array(fingerViews.values)
        let selectedFinger = allFingers.randomElement()
        
        animateSelection(selectedFinger: selectedFinger)
    }
    
    private func animateSelection(selectedFinger: UIView?) {
        UIView.animate(withDuration: 0.5) {
            for fingerView in self.fingerViews.values {
                if fingerView == selectedFinger {
                    fingerView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                    fingerView.backgroundColor = self.currentQuestionType == .truth ?
                        UIColor(hex: "84C500") : UIColor(hex: "5800CF")
                } else {
                    fingerView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                    fingerView.backgroundColor = .gray
                }
            }
        }
    }
}


