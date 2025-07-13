//
//  RatingPopupViewController.swift
//  Bulb
//
//  Pop-up контроллер для оценки подборки
//

import UIKit

protocol RatingPopupDelegate: AnyObject {
    func didSubmitRating(_ rating: Int)
    func didSkipRating()
    func didReturnToGame()
}

class RatingPopupViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: RatingPopupDelegate?
    private var selectedRating: Int = 0
    private var starButtons: [UIButton] = []
    
    // MARK: - UI Components
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var popupContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowRadius = 20
        view.layer.shadowOpacity = 0.3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Оцените подборку"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Ваша оценка поможет другим игрокам"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var starsContainerView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var ratingDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Выберите оценку"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Оценить", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor(hex: "84C500")
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.alpha = 0.5
        button.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Нет, спасибо", for: .normal)
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var returnButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вернуться в игру", for: .normal)
        button.setTitleColor(UIColor(hex: "5800CF"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = UIColor(hex: "5800CF").withAlphaComponent(0.1)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(returnButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStars()
        setupTapGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateAppearance()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.addSubview(backgroundView)
        view.addSubview(popupContainerView)
        
        popupContainerView.addSubview(titleLabel)
        popupContainerView.addSubview(subtitleLabel)
        popupContainerView.addSubview(starsContainerView)
        popupContainerView.addSubview(ratingDescriptionLabel)
        popupContainerView.addSubview(buttonsStackView)
        
        buttonsStackView.addArrangedSubview(submitButton)
        buttonsStackView.addArrangedSubview(skipButton)
        buttonsStackView.addArrangedSubview(returnButton)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            popupContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popupContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            popupContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            popupContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            titleLabel.topAnchor.constraint(equalTo: popupContainerView.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: popupContainerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: popupContainerView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: popupContainerView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: popupContainerView.trailingAnchor, constant: -20),
            
            starsContainerView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            starsContainerView.centerXAnchor.constraint(equalTo: popupContainerView.centerXAnchor),
            starsContainerView.heightAnchor.constraint(equalToConstant: 50),
            starsContainerView.widthAnchor.constraint(equalToConstant: 280),
            
            ratingDescriptionLabel.topAnchor.constraint(equalTo: starsContainerView.bottomAnchor, constant: 16),
            ratingDescriptionLabel.leadingAnchor.constraint(equalTo: popupContainerView.leadingAnchor, constant: 20),
            ratingDescriptionLabel.trailingAnchor.constraint(equalTo: popupContainerView.trailingAnchor, constant: -20),
            
            buttonsStackView.topAnchor.constraint(equalTo: ratingDescriptionLabel.bottomAnchor, constant: 30),
            buttonsStackView.leadingAnchor.constraint(equalTo: popupContainerView.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: popupContainerView.trailingAnchor, constant: -20),
            buttonsStackView.bottomAnchor.constraint(equalTo: popupContainerView.bottomAnchor, constant: -30),
            
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            skipButton.heightAnchor.constraint(equalToConstant: 44),
            returnButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupStars() {
        starButtons.removeAll()
        
        for i in 1...5 {
            let starButton = createStarButton(tag: i)
            starsContainerView.addArrangedSubview(starButton)
            starButtons.append(starButton)
        }
    }
    
    private func createStarButton(tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = tag
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.setImage(UIImage(systemName: "star.fill"), for: .selected)
        button.tintColor = .systemGray4
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(starButtonTapped(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 50),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        return button
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        backgroundView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Animation Methods
    
    private func animateAppearance() {
        popupContainerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        popupContainerView.alpha = 0
        backgroundView.alpha = 0
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            self.popupContainerView.transform = .identity
            self.popupContainerView.alpha = 1
            self.backgroundView.alpha = 1
        })
    }
    
    private func animateDisappearance(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.25, animations: {
            self.popupContainerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.popupContainerView.alpha = 0
            self.backgroundView.alpha = 0
        }) { _ in
            completion()
        }
    }
    
    // MARK: - Star Rating Methods
    
    private func updateStarSelection() {
        for (index, button) in starButtons.enumerated() {
            let starNumber = index + 1
            let isSelected = starNumber <= selectedRating
            
            button.isSelected = isSelected
            button.tintColor = isSelected ? .systemYellow : .systemGray4
            
            // Добавляем анимацию при выборе
            if isSelected {
                UIView.animate(withDuration: 0.15, animations: {
                    button.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }) { _ in
                    UIView.animate(withDuration: 0.15) {
                        button.transform = .identity
                    }
                }
            }
        }
        
        // Обновляем состояние кнопки "Оценить"
        submitButton.isEnabled = selectedRating > 0
        submitButton.alpha = selectedRating > 0 ? 1.0 : 0.5
        
        // Обновляем описание рейтинга
        updateRatingDescription()
    }
    
    private func updateRatingDescription() {
        let descriptions = [
            0: "Выберите оценку",
            1: "Очень плохо",
            2: "Плохо",
            3: "Нормально",
            4: "Хорошо",
            5: "Отлично!"
        ]
        
        ratingDescriptionLabel.text = descriptions[selectedRating]
        ratingDescriptionLabel.textColor = selectedRating > 0 ? .label : .secondaryLabel
    }
    
    // MARK: - Actions
    
    @objc private func starButtonTapped(_ sender: UIButton) {
        selectedRating = sender.tag
        updateStarSelection()
        
        // Вибрация при выборе звезды
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    @objc private func submitButtonTapped() {
        guard selectedRating > 0 else { return }
        
        // Вибрация успеха
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        animateDisappearance { [weak self] in
            guard let self = self else { return }
            self.delegate?.didSubmitRating(self.selectedRating)
            self.dismiss(animated: false)
        }
    }
    
    @objc private func skipButtonTapped() {
        animateDisappearance { [weak self] in
            self?.delegate?.didSkipRating()
            self?.dismiss(animated: false)
        }
    }
    
    @objc private func returnButtonTapped() {
        animateDisappearance { [weak self] in
            self?.delegate?.didReturnToGame()
            self?.dismiss(animated: false)
        }
    }
    
    @objc private func backgroundTapped() {
        // При тапе на фон возвращаемся в игру
        returnButtonTapped()
    }
}


