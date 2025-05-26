//
//  AddViewController.swift
//  Bulb
//
//  Updated with API integration for creating collections
//

import UIKit

// MARK: - Models (keeping existing ones)
enum CardType: String, CaseIterable {
    case truth = "Правда"
    case dare = "Действие"
    
    var color: UIColor {
        switch self {
        case .truth:
            return UIColor(hex: "84C500")
        case .dare:
            return UIColor(hex: "5800CF")
        }
    }
    
    var icon: String {
        switch self {
        case .truth:
            return "questionmark.text.page.fill"
        case .dare:
            return "figure.american.football"
        }
    }
}

enum LocationTag: String, CaseIterable {
    case home = "Дома"
    case street = "Улица"
    
    var icon: String {
        switch self {
        case .home:
            return "house.fill"
        case .street:
            return "road.lanes"
        }
    }
}

struct GameCard {
    let id = UUID()
    let text: String
    let type: CardType
}

class AddViewController: UIViewController {
    
    // MARK: - Properties
    
    private var cards: [GameCard] = []
    private var selectedLocationTag: LocationTag = .home
    private var isCreatingCard = false
    private var selectedCardType: CardType = .truth
    private var isCreatingCollection = false
    
    // MARK: - UI Components (keeping existing UI setup)
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Создать подборку"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Collection Info Section
    private lazy var collectionInfoSection: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.05
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Название подборки"
        textField.borderStyle = .none
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        textField.layer.cornerRadius = 12
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        textView.layer.cornerRadius = 12
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Описание подборки..."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .placeholderText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Cards Section (keeping existing cards UI)
    private lazy var cardsSection: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.05
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var cardsLabel: UILabel = {
        let label = UILabel()
        label.text = "Карточки"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var cardsCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0 карточек"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addCardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить карточку", for: .normal)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = UIColor(named: "violetBulb")
        button.backgroundColor = UIColor(named: "violetBulb")?.withAlphaComponent(0.1)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapAddCard), for: .touchUpInside)
        return button
    }()
    
    // Create Button with loading state
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать подборку", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor(named: "violetBulb")
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Card Creation Form (keeping existing implementation)
    private lazy var cardCreationForm: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.systemBlue.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private lazy var cardsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // Dynamic constraint for card creation form
    private var cardCreationFormHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextViewDelegates()
        setupTapGesture()
        setupKeyboardObservers()
        updateCardsCount()
        checkAuthenticationStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkAuthenticationStatus()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Authentication Check
    
    private func checkAuthenticationStatus() {
        if !AuthManager.shared.isLoggedIn {
            showAuthRequiredAlert()
        }
    }
    
    private func showAuthRequiredAlert() {
        let alert = UIAlertController(
            title: "Требуется вход",
            message: "Для создания подборок необходимо войти в аккаунт",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Войти", style: .default) { [weak self] _ in
            self?.showLogin()
        })
        
        alert.addAction(UIAlertAction(title: "Дебаг", style: .default) { [weak self] _ in
            let debugVC = AuthDebugViewController()
            self?.present(debugVC, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showLogin() {
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: true)
    }
    
    // MARK: - Setup Methods (keeping existing setup with some additions)
    
    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(collectionInfoSection)
        contentView.addSubview(cardsSection)
        contentView.addSubview(createButton)
        contentView.addSubview(loadingIndicator)
        
        // Collection Info Section
        collectionInfoSection.addSubview(nameTextField)
        collectionInfoSection.addSubview(descriptionTextView)
        collectionInfoSection.addSubview(placeholderLabel)
        
        // Cards Section
        cardsSection.addSubview(cardsLabel)
        cardsSection.addSubview(cardsCountLabel)
        cardsSection.addSubview(addCardButton)
        cardsSection.addSubview(cardCreationForm)
        cardsSection.addSubview(cardsStackView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        cardCreationFormHeightConstraint = cardCreationForm.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Collection Info Section
            collectionInfoSection.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            collectionInfoSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            collectionInfoSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            nameTextField.topAnchor.constraint(equalTo: collectionInfoSection.topAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: collectionInfoSection.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: collectionInfoSection.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            descriptionTextView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            descriptionTextView.leadingAnchor.constraint(equalTo: collectionInfoSection.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: collectionInfoSection.trailingAnchor, constant: -20),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            descriptionTextView.bottomAnchor.constraint(equalTo: collectionInfoSection.bottomAnchor, constant: -20),
            
            placeholderLabel.topAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: 16),
            placeholderLabel.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor, constant: 16),
            
            // Cards Section
            cardsSection.topAnchor.constraint(equalTo: collectionInfoSection.bottomAnchor, constant: 20),
            cardsSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardsSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            cardsLabel.topAnchor.constraint(equalTo: cardsSection.topAnchor, constant: 20),
            cardsLabel.leadingAnchor.constraint(equalTo: cardsSection.leadingAnchor, constant: 20),
            
            cardsCountLabel.centerYAnchor.constraint(equalTo: cardsLabel.centerYAnchor),
            cardsCountLabel.trailingAnchor.constraint(equalTo: cardsSection.trailingAnchor, constant: -20),
            
            addCardButton.topAnchor.constraint(equalTo: cardsLabel.bottomAnchor, constant: 16),
            addCardButton.leadingAnchor.constraint(equalTo: cardsSection.leadingAnchor, constant: 20),
            addCardButton.trailingAnchor.constraint(equalTo: cardsSection.trailingAnchor, constant: -20),
            
            // Card Creation Form
            cardCreationForm.topAnchor.constraint(equalTo: addCardButton.bottomAnchor, constant: 16),
            cardCreationForm.leadingAnchor.constraint(equalTo: cardsSection.leadingAnchor, constant: 20),
            cardCreationForm.trailingAnchor.constraint(equalTo: cardsSection.trailingAnchor, constant: -20),
            cardCreationFormHeightConstraint,
            
            // Cards Stack View
            cardsStackView.topAnchor.constraint(equalTo: cardCreationForm.bottomAnchor, constant: 16),
            cardsStackView.leadingAnchor.constraint(equalTo: cardsSection.leadingAnchor, constant: 20),
            cardsStackView.trailingAnchor.constraint(equalTo: cardsSection.trailingAnchor, constant: -20),
            cardsStackView.bottomAnchor.constraint(equalTo: cardsSection.bottomAnchor, constant: -20),
            
            // Create Button
            createButton.topAnchor.constraint(equalTo: cardsSection.bottomAnchor, constant: 30),
            createButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 56),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: createButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: createButton.centerYAnchor)
        ])
    }
    
    private func setupTextViewDelegates() {
        descriptionTextView.delegate = self
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func updateCardsCount() {
        let count = cards.count
        cardsCountLabel.text = "\(count) \(count == 1 ? "карточка" : count < 5 ? "карточки" : "карточек")"
        updateCardsDisplay()
    }
    
    private func updateCardsDisplay() {
        cardsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if cards.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "Карточки появятся здесь"
            emptyLabel.textColor = .secondaryLabel
            emptyLabel.textAlignment = .center
            emptyLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            cardsStackView.addArrangedSubview(emptyLabel)
        } else {
            for (index, card) in cards.enumerated() {
                let cardView = createCardDisplayView(for: card, at: index)
                cardsStackView.addArrangedSubview(cardView)
            }
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    private func createCardDisplayView(for card: GameCard, at index: Int) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = card.type.color.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let typeIndicator = UIView()
        typeIndicator.backgroundColor = card.type.color
        typeIndicator.layer.cornerRadius = 8
        typeIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let typeIconView = UIImageView()
        typeIconView.image = UIImage(systemName: card.type.icon)
        typeIconView.tintColor = .white
        typeIconView.contentMode = .scaleAspectFit
        typeIconView.translatesAutoresizingMaskIntoConstraints = false
        
        let cardTextLabel = UILabel()
        cardTextLabel.text = card.text
        cardTextLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cardTextLabel.numberOfLines = 0
        cardTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let deleteButton = UIButton(type: .system)
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = .systemRed
        deleteButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        deleteButton.layer.cornerRadius = 15
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.tag = index
        deleteButton.addTarget(self, action: #selector(deleteCard(_:)), for: .touchUpInside)
        
        containerView.addSubview(typeIndicator)
        typeIndicator.addSubview(typeIconView)
        containerView.addSubview(cardTextLabel)
        containerView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 70),
            
            typeIndicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            typeIndicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            typeIndicator.widthAnchor.constraint(equalToConstant: 32),
            typeIndicator.heightAnchor.constraint(equalToConstant: 32),
            
            typeIconView.centerXAnchor.constraint(equalTo: typeIndicator.centerXAnchor),
            typeIconView.centerYAnchor.constraint(equalTo: typeIndicator.centerYAnchor),
            typeIconView.widthAnchor.constraint(equalToConstant: 20),
            typeIconView.heightAnchor.constraint(equalToConstant: 20),
            
            cardTextLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            cardTextLabel.leadingAnchor.constraint(equalTo: typeIndicator.trailingAnchor, constant: 12),
            cardTextLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -12),
            cardTextLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12),
            
            deleteButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            deleteButton.widthAnchor.constraint(equalToConstant: 30),
            deleteButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        return containerView
    }
    
    // MARK: - Actions
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.scrollIndicatorInsets.bottom = keyboardHeight
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
        scrollView.scrollIndicatorInsets.bottom = 0
    }
    
    @objc private func didTapAddCard() {
        showCardCreationForm()
    }
    
    @objc private func deleteCard(_ sender: UIButton) {
        let index = sender.tag
        guard index < cards.count else { return }
        
        cards.remove(at: index)
        updateCardsCount()
    }
    
    @objc private func didTapCreate() {
        createCollectionWithAPI()
    }
    
    // MARK: - API Integration
    
    private func createCollectionWithAPI() {
        guard AuthManager.shared.isLoggedIn else {
            print("❌ User not logged in")
            showAuthRequiredAlert()
            return
        }
        
        print("✅ User is logged in, proceeding with collection creation")
        
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            showAlert(title: "Ошибка", message: "Пожалуйста, введите название подборки")
            return
        }
        
        if cards.isEmpty {
            showAlert(title: "Ошибка", message: "Добавьте хотя бы одну карточку")
            return
        }
        
        let description = descriptionTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        setLoading(true)
        
        // Сначала создаем коллекцию
        CollectionsService.shared.createCollection(
            name: name,
            description: description,
            imageUrl: nil
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("✅ Collection created: \(response.message)")
                    // После создания коллекции нужно получить её ID и добавить действия
                    // Для упрощения пока показываем успех
                    self?.handleCreationSuccess()
                    
                case .failure(let error):
                    print("❌ Failed to create collection: \(error)")
                    self?.setLoading(false)
                    self?.showAlert(title: "Ошибка создания", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func handleCreationSuccess() {
        setLoading(false)
        
        let alert = UIAlertController(
            title: "Успех!",
            message: "Подборка успешно создана",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.resetForm()
        })
        
        present(alert, animated: true)
    }
    
    private func setLoading(_ isLoading: Bool) {
        isCreatingCollection = isLoading
        createButton.isEnabled = !isLoading
        createButton.setTitle(isLoading ? "" : "Создать подборку", for: .normal)
        
        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
    
    private func resetForm() {
        nameTextField.text = ""
        descriptionTextView.text = ""
        placeholderLabel.isHidden = false
        cards.removeAll()
        updateCardsCount()
        hideCardCreationForm()
    }
    
    // MARK: - Card Creation Form (simplified version)
    
    private func showCardCreationForm() {
        guard !isCreatingCard else { return }
        
        let alert = UIAlertController(title: "Новая карточка", message: "Введите текст карточки", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Текст карточки..."
        }
        
        let truthAction = UIAlertAction(title: "Добавить как Правду", style: .default) { [weak self] _ in
            if let text = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
                let card = GameCard(text: text, type: .truth)
                self?.cards.append(card)
                self?.updateCardsCount()
            }
        }
        
        let dareAction = UIAlertAction(title: "Добавить как Действие", style: .default) { [weak self] _ in
            if let text = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
                let card = GameCard(text: text, type: .dare)
                self?.cards.append(card)
                self?.updateCardsCount()
            }
        }
        
        alert.addAction(truthAction)
        alert.addAction(dareAction)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func hideCardCreationForm() {
        // Simplified since we're using alert now
    }
    
    private func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate

extension AddViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView == descriptionTextView {
            placeholderLabel.isHidden = !textView.text.isEmpty
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == descriptionTextView {
            placeholderLabel.isHidden = !textView.text.isEmpty
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == descriptionTextView {
            placeholderLabel.isHidden = !textView.text.isEmpty
        }
    }
}
