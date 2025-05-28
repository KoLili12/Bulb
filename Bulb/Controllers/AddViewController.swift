//
//  AddViewController.swift
//  Bulb
//
//  Updated with new card creation form
//

import UIKit

// MARK: - Models
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
    private var selectedCardType: CardType = .truth
    private var isCreatingCollection = false
    
    // Card Creation Form Properties
    private var cardTextView: UITextView!
    private var characterCountLabel: UILabel!
    private var truthButton: UIButton!
    private var dareButton: UIButton!
    private var truthIcon: UIImageView!
    private var dareIcon: UIImageView!
    
    // MARK: - UI Components
    
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
    
    // Cards Section
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
    
    // Card Creation Form
    private lazy var cardCreationForm: UIView = {
        let view = UIView()
        view.backgroundColor = .white
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
    
    // Create Button
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
    
    // MARK: - Setup Methods
    
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
    
    // MARK: - Card Creation Form Methods
    
    @objc private func didTapAddCard() {
        showCardCreationFormView()
    }
    
    private func showCardCreationFormView() {
        cardCreationForm.isHidden = false
        setupCardCreationFormContent()
        
        cardCreationFormHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            self.view.layoutIfNeeded()
        })
        
        cardTextView.becomeFirstResponder()
    }
    
    private func setupCardCreationFormContent() {
        cardCreationForm.subviews.forEach { $0.removeFromSuperview() }
        
        let textView = createCardTextView()
        let characterCountLabel = createCharacterCountLabel()
        let typeSelector = createTypeSelector()
        let buttonsContainer = createButtonsContainer()
        
        cardCreationForm.addSubview(textView)
        cardCreationForm.addSubview(characterCountLabel)
        cardCreationForm.addSubview(typeSelector)
        cardCreationForm.addSubview(buttonsContainer)
        
        self.cardTextView = textView
        self.characterCountLabel = characterCountLabel
        
        setupCardCreationConstraints(textView: textView, characterCountLabel: characterCountLabel, typeSelector: typeSelector, buttonsContainer: buttonsContainer)
    }
    
    private func createCardTextView() -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = UIColor.systemGray6
        textView.layer.cornerRadius = 12
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        textView.text = "Введите текст карточки..."
        textView.textColor = UIColor.placeholderText
        
        return textView
    }
    
    private func createCharacterCountLabel() -> UILabel {
        let label = UILabel()
        label.text = "0/170"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createTypeSelector() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // Кнопка "Правда" - делаем шире и овальной
        let truthButton = UIButton(type: .system)
        truthButton.setTitle("  Правда", for: .normal) // Пробелы для иконки
        truthButton.setTitleColor(.white, for: .normal)
        truthButton.backgroundColor = UIColor(hex: "84C500")
        truthButton.layer.cornerRadius = 25 // Увеличиваем радиус
        truthButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        truthButton.translatesAutoresizingMaskIntoConstraints = false
        truthButton.tag = 0
        truthButton.addTarget(self, action: #selector(cardTypeSelected(_:)), for: .touchUpInside)
        
        // Иконка для "Правды" - белый квадрат с вопросом
        let questionIcon = UIImageView()
        questionIcon.image = UIImage(systemName: "questionmark.square.fill")
        questionIcon.tintColor = .white
        questionIcon.translatesAutoresizingMaskIntoConstraints = false
        truthButton.addSubview(questionIcon)
        
        // Кнопка "Действие" - делаем шире и овальной
        let dareButton = UIButton(type: .system)
        dareButton.setTitle("  Действие", for: .normal) // Пробелы для иконки
        dareButton.setTitleColor(.systemGray, for: .normal)
        dareButton.backgroundColor = UIColor.systemGray5
        dareButton.layer.cornerRadius = 25 // Увеличиваем радиус
        dareButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        dareButton.translatesAutoresizingMaskIntoConstraints = false
        dareButton.tag = 1
        dareButton.addTarget(self, action: #selector(cardTypeSelected(_:)), for: .touchUpInside)
        
        // Иконка для "Действия" - человечек
        let actionIcon = UIImageView()
        actionIcon.image = UIImage(systemName: "figure.run")
        actionIcon.tintColor = .systemGray
        actionIcon.translatesAutoresizingMaskIntoConstraints = false
        dareButton.addSubview(actionIcon)
        
        container.addSubview(truthButton)
        container.addSubview(dareButton)
        
        self.truthButton = truthButton
        self.dareButton = dareButton
        self.truthIcon = questionIcon
        self.dareIcon = actionIcon
        
        NSLayoutConstraint.activate([
            // Кнопка "Правда" - увеличиваем размеры
            truthButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            truthButton.topAnchor.constraint(equalTo: container.topAnchor),
            truthButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            truthButton.widthAnchor.constraint(equalToConstant: 160), // Увеличиваем ширину
            truthButton.heightAnchor.constraint(equalToConstant: 50), // Увеличиваем высоту
            
            // Иконка в кнопке "Правда"
            questionIcon.leadingAnchor.constraint(equalTo: truthButton.leadingAnchor, constant: 20),
            questionIcon.centerYAnchor.constraint(equalTo: truthButton.centerYAnchor),
            questionIcon.widthAnchor.constraint(equalToConstant: 20), // Увеличиваем иконку
            questionIcon.heightAnchor.constraint(equalToConstant: 20),
            
            // Кнопка "Действие" - увеличиваем размеры
            dareButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            dareButton.topAnchor.constraint(equalTo: container.topAnchor),
            dareButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            dareButton.widthAnchor.constraint(equalToConstant: 160), // Увеличиваем ширину
            dareButton.heightAnchor.constraint(equalToConstant: 50), // Увеличиваем высоту
            
            // Иконка в кнопке "Действие"
            actionIcon.leadingAnchor.constraint(equalTo: dareButton.leadingAnchor, constant: 20),
            actionIcon.centerYAnchor.constraint(equalTo: dareButton.centerYAnchor),
            actionIcon.widthAnchor.constraint(equalToConstant: 20), // Увеличиваем иконку
            actionIcon.heightAnchor.constraint(equalToConstant: 20),
            
            container.heightAnchor.constraint(equalToConstant: 50) // Увеличиваем высоту контейнера
        ])
        
        return container
    }
    
    private func createButtonsContainer() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // Кнопка "Отмена" - делаем больше и овальной
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Отмена", for: .normal)
        cancelButton.setTitleColor(.systemRed, for: .normal)
        cancelButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        cancelButton.layer.cornerRadius = 25 // Увеличиваем радиус
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelCardCreation), for: .touchUpInside)
        
        // Кнопка "Добавить" - делаем больше и овальной
        let addButton = UIButton(type: .system)
        addButton.setTitle("Добавить", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = UIColor.systemBlue
        addButton.layer.cornerRadius = 25 // Увеличиваем радиус
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addCardToCollection), for: .touchUpInside)
        
        container.addSubview(cancelButton)
        container.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            // Увеличиваем размеры кнопок
            cancelButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            cancelButton.topAnchor.constraint(equalTo: container.topAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 140), // Увеличиваем ширину
            cancelButton.heightAnchor.constraint(equalToConstant: 50), // Увеличиваем высоту
            
            addButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            addButton.topAnchor.constraint(equalTo: container.topAnchor),
            addButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 160), // Увеличиваем ширину
            addButton.heightAnchor.constraint(equalToConstant: 50), // Увеличиваем высоту
            
            container.heightAnchor.constraint(equalToConstant: 50) // Увеличиваем высоту контейнера
        ])
        
        return container
    }
    
    private func setupCardCreationConstraints(textView: UITextView, characterCountLabel: UILabel, typeSelector: UIView, buttonsContainer: UIView) {
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: cardCreationForm.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: cardCreationForm.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: cardCreationForm.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 120),
            
            characterCountLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 8),
            characterCountLabel.trailingAnchor.constraint(equalTo: cardCreationForm.trailingAnchor, constant: -16),
            
            typeSelector.topAnchor.constraint(equalTo: characterCountLabel.bottomAnchor, constant: 16),
            typeSelector.leadingAnchor.constraint(equalTo: cardCreationForm.leadingAnchor, constant: 16),
            typeSelector.trailingAnchor.constraint(equalTo: cardCreationForm.trailingAnchor, constant: -16),
            
            buttonsContainer.topAnchor.constraint(equalTo: typeSelector.bottomAnchor, constant: 20),
            buttonsContainer.leadingAnchor.constraint(equalTo: cardCreationForm.leadingAnchor, constant: 16),
            buttonsContainer.trailingAnchor.constraint(equalTo: cardCreationForm.trailingAnchor, constant: -16),
            buttonsContainer.bottomAnchor.constraint(equalTo: cardCreationForm.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Card Creation Actions
    
    @objc private func cardTypeSelected(_ sender: UIButton) {
        let isSelectingTruth = sender.tag == 0
        selectedCardType = isSelectingTruth ? .truth : .dare
        
        UIView.animate(withDuration: 0.2) {
            if isSelectingTruth {
                self.truthButton.backgroundColor = UIColor(hex: "84C500")
                self.truthButton.setTitleColor(.white, for: .normal)
                self.truthIcon.tintColor = .white
                
                self.dareButton.backgroundColor = UIColor.systemGray5
                self.dareButton.setTitleColor(.systemGray, for: .normal)
                self.dareIcon.tintColor = .systemGray
            } else {
                self.dareButton.backgroundColor = UIColor(hex: "5800CF")
                self.dareButton.setTitleColor(.white, for: .normal)
                self.dareIcon.tintColor = .white
                
                self.truthButton.backgroundColor = UIColor.systemGray5
                self.truthButton.setTitleColor(.systemGray, for: .normal)
                self.truthIcon.tintColor = .systemGray
            }
        }
        
        updatePlaceholderForCardType()
    }
    
    private func updatePlaceholderForCardType() {
        if cardTextView.text == "Введите текст карточки..." || cardTextView.textColor == UIColor.placeholderText {
            let placeholderText = selectedCardType == .truth ?
                "Например: Самый странный сон, который ты помнишь?" :
                "Например: Станцуй без музыки 30 секунд"
            
            cardTextView.text = placeholderText
            cardTextView.textColor = UIColor.placeholderText
        }
    }
    
    @objc private func cancelCardCreation() {
        hideCardCreationForm()
    }
    
    @objc private func addCardToCollection() {
        guard let text = cardTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty,
              text != "Введите текст карточки...",
              cardTextView.textColor != UIColor.placeholderText else {
            showAlert(title: "Ошибка", message: "Пожалуйста, введите текст карточки")
            return
        }
        
        if text.count > 170 {
            showAlert(title: "Ошибка", message: "Текст карточки не должен превышать 170 символов")
            return
        }
        
        let card = GameCard(text: text, type: selectedCardType)
        cards.append(card)
        updateCardsCount()
        hideCardCreationForm()
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func hideCardCreationForm() {
        cardCreationFormHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            self.cardCreationForm.isHidden = true
            self.cardTextView.resignFirstResponder()
        }
    }
    
    // MARK: - Cards Management
    
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
    
    @objc private func deleteCard(_ sender: UIButton) {
        let index = sender.tag
        guard index < cards.count else { return }
        
        cards.remove(at: index)
        updateCardsCount()
    }
    
    // MARK: - Keyboard Handling
    
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
    
    // MARK: - API Integration
    
    @objc private func didTapCreate() {
        createCollectionWithAPI()
    }
    
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
        
        CollectionsService.shared.createCollection(
            name: name,
            description: description,
            imageUrl: nil
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("✅ Collection created: \(response.message)")
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
    
    private func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate

extension AddViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == cardTextView && textView.textColor == UIColor.placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
        
        if textView == descriptionTextView {
            placeholderLabel.isHidden = !textView.text.isEmpty
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == cardTextView && textView.text.isEmpty {
            textView.text = "Введите текст карточки..."
            textView.textColor = UIColor.placeholderText
        }
        
        if textView == descriptionTextView {
            placeholderLabel.isHidden = !textView.text.isEmpty
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == cardTextView {
            let count = textView.text.count
            characterCountLabel.text = "\(count)/170"
            
            characterCountLabel.textColor = count > 170 ? .systemRed : .secondaryLabel
        }
        
        if textView == descriptionTextView {
            placeholderLabel.isHidden = !textView.text.isEmpty
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == cardTextView {
            let currentText = textView.text ?? ""
            let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
            return updatedText.count <= 170
        }
        return true
    }
}
