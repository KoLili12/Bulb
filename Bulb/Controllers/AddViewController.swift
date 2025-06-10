//
//  AddViewController.swift
//  Bulb
//
//  Complete implementation with all missing methods
//

import UIKit

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
        label.numberOfLines = 2
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
            cardsCountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: cardsLabel.trailingAnchor, constant: 10),
            
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
    
    // MARK: - Card Management Methods
    
    private func updateCardsCount() {
        let count = cards.count
        let truthCount = cards.filter { $0.type == .truth }.count
        let dareCount = cards.filter { $0.type == .dare }.count
        
        // Основной текст с количеством карточек
        let mainText = "\(count) \(getCardWord(for: count))"
        
        // Детальная статистика по типам
        let detailText: String
        if count > 0 {
            detailText = "👤 \(truthCount) • 🎯 \(dareCount)"
        } else {
            detailText = "Добавьте карточки"
        }
        
        // Создаем атрибутированный текст
        let attributedText = NSMutableAttributedString()
        
        // Основной текст
        attributedText.append(NSAttributedString(
            string: mainText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .foregroundColor: UIColor.secondaryLabel
            ]
        ))
        
        // Переход на новую строку
        attributedText.append(NSAttributedString(string: "\n"))
        
        // Детальная статистика
        attributedText.append(NSAttributedString(
            string: detailText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: count > 0 ? UIColor.systemBlue : UIColor.tertiaryLabel
            ]
        ))
        
        cardsCountLabel.attributedText = attributedText
        updateCardsDisplay()
    }
    
    private func getCardWord(for count: Int) -> String {
        switch count {
        case 1:
            return "карточка"
        case 2...4:
            return "карточки"
        default:
            return "карточек"
        }
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
        let cardView = UIView()
        cardView.backgroundColor = .systemGray6
        cardView.layer.cornerRadius = 12
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        // Type indicator
        let typeIndicator = UIView()
        typeIndicator.backgroundColor = card.type.color
        typeIndicator.layer.cornerRadius = 4
        typeIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        // Type label
        let typeLabel = UILabel()
        typeLabel.text = card.type.emoji + " " + card.type.displayName
        typeLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        typeLabel.textColor = card.type.color
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Card text
        let cardTextLabel = UILabel()
        cardTextLabel.text = card.text
        cardTextLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        cardTextLabel.numberOfLines = 0
        cardTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Delete button
        let deleteButton = UIButton(type: .system)
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = .systemRed
        deleteButton.tag = index
        deleteButton.addTarget(self, action: #selector(deleteCard(_:)), for: .touchUpInside)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(typeIndicator)
        cardView.addSubview(typeLabel)
        cardView.addSubview(cardTextLabel)
        cardView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            typeIndicator.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            typeIndicator.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            typeIndicator.widthAnchor.constraint(equalToConstant: 4),
            typeIndicator.heightAnchor.constraint(equalToConstant: 20),
            
            typeLabel.centerYAnchor.constraint(equalTo: typeIndicator.centerYAnchor),
            typeLabel.leadingAnchor.constraint(equalTo: typeIndicator.trailingAnchor, constant: 8),
            
            deleteButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            deleteButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            deleteButton.widthAnchor.constraint(equalToConstant: 24),
            deleteButton.heightAnchor.constraint(equalToConstant: 24),
            
            cardTextLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 8),
            cardTextLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            cardTextLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -8),
            cardTextLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
        ])
        
        return cardView
    }
    
    // MARK: - Card Creation Form Methods
    
    @objc private func didTapAddCard() {
        showCardCreationForm()
    }
    
    private func showCardCreationForm() {
        cardCreationForm.isHidden = false
        setupCardCreationFormContent()
        
        cardCreationFormHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            self.view.layoutIfNeeded()
        })
        
        cardTextView.becomeFirstResponder()
    }
    
    private func setupCardCreationFormContent() {
        // Clear previous content
        cardCreationForm.subviews.forEach { $0.removeFromSuperview() }
        
        // Header
        let headerLabel = UILabel()
        headerLabel.text = "Новая карточка"
        headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Text view
        cardTextView = UITextView()
        cardTextView.font = UIFont.systemFont(ofSize: 16)
        cardTextView.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        cardTextView.layer.cornerRadius = 12
        cardTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        cardTextView.delegate = self
        cardTextView.translatesAutoresizingMaskIntoConstraints = false
        
        // Character count
        characterCountLabel = UILabel()
        characterCountLabel.text = "0/170"
        characterCountLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        characterCountLabel.textColor = .secondaryLabel
        characterCountLabel.textAlignment = .right
        characterCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Type selection
        let typeSelectionContainer = UIView()
        typeSelectionContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Truth button
        truthButton = UIButton(type: .system)
        truthButton.setTitle("👤 Правда", for: .normal)
        truthButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        truthButton.backgroundColor = CardType.truth.color
        truthButton.setTitleColor(.white, for: .normal)
        truthButton.layer.cornerRadius = 12
        truthButton.addTarget(self, action: #selector(selectTruthType), for: .touchUpInside)
        truthButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Dare button
        dareButton = UIButton(type: .system)
        dareButton.setTitle("🎯 Действие", for: .normal)
        dareButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        dareButton.backgroundColor = .systemGray5
        dareButton.setTitleColor(.label, for: .normal)
        dareButton.layer.cornerRadius = 12
        dareButton.addTarget(self, action: #selector(selectDareType), for: .touchUpInside)
        dareButton.translatesAutoresizingMaskIntoConstraints = false
        
        typeSelectionContainer.addSubview(truthButton)
        typeSelectionContainer.addSubview(dareButton)
        
        // Action buttons
        let buttonsContainer = UIView()
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Отмена", for: .normal)
        cancelButton.setTitleColor(.systemRed, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelCardCreation), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = UIColor(named: "violetBulb")
        saveButton.layer.cornerRadius = 8
        saveButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        saveButton.addTarget(self, action: #selector(saveCard), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        buttonsContainer.addSubview(cancelButton)
        buttonsContainer.addSubview(saveButton)
        
        // Add all to form
        cardCreationForm.addSubview(headerLabel)
        cardCreationForm.addSubview(cardTextView)
        cardCreationForm.addSubview(characterCountLabel)
        cardCreationForm.addSubview(typeSelectionContainer)
        cardCreationForm.addSubview(buttonsContainer)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: cardCreationForm.topAnchor, constant: 16),
            headerLabel.leadingAnchor.constraint(equalTo: cardCreationForm.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: cardCreationForm.trailingAnchor, constant: -16),
            
            cardTextView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 16),
            cardTextView.leadingAnchor.constraint(equalTo: cardCreationForm.leadingAnchor, constant: 16),
            cardTextView.trailingAnchor.constraint(equalTo: cardCreationForm.trailingAnchor, constant: -16),
            cardTextView.heightAnchor.constraint(equalToConstant: 100),
            
            characterCountLabel.topAnchor.constraint(equalTo: cardTextView.bottomAnchor, constant: 4),
            characterCountLabel.trailingAnchor.constraint(equalTo: cardCreationForm.trailingAnchor, constant: -16),
            
            typeSelectionContainer.topAnchor.constraint(equalTo: characterCountLabel.bottomAnchor, constant: 16),
            typeSelectionContainer.leadingAnchor.constraint(equalTo: cardCreationForm.leadingAnchor, constant: 16),
            typeSelectionContainer.trailingAnchor.constraint(equalTo: cardCreationForm.trailingAnchor, constant: -16),
            typeSelectionContainer.heightAnchor.constraint(equalToConstant: 44),
            
            truthButton.topAnchor.constraint(equalTo: typeSelectionContainer.topAnchor),
            truthButton.leadingAnchor.constraint(equalTo: typeSelectionContainer.leadingAnchor),
            truthButton.bottomAnchor.constraint(equalTo: typeSelectionContainer.bottomAnchor),
            truthButton.widthAnchor.constraint(equalTo: typeSelectionContainer.widthAnchor, multiplier: 0.48),
            
            dareButton.topAnchor.constraint(equalTo: typeSelectionContainer.topAnchor),
            dareButton.trailingAnchor.constraint(equalTo: typeSelectionContainer.trailingAnchor),
            dareButton.bottomAnchor.constraint(equalTo: typeSelectionContainer.bottomAnchor),
            dareButton.widthAnchor.constraint(equalTo: typeSelectionContainer.widthAnchor, multiplier: 0.48),
            
            buttonsContainer.topAnchor.constraint(equalTo: typeSelectionContainer.bottomAnchor, constant: 16),
            buttonsContainer.leadingAnchor.constraint(equalTo: cardCreationForm.leadingAnchor, constant: 16),
            buttonsContainer.trailingAnchor.constraint(equalTo: cardCreationForm.trailingAnchor, constant: -16),
            buttonsContainer.bottomAnchor.constraint(equalTo: cardCreationForm.bottomAnchor, constant: -16),
            buttonsContainer.heightAnchor.constraint(equalToConstant: 44),
            
            cancelButton.centerYAnchor.constraint(equalTo: buttonsContainer.centerYAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor),
            
            saveButton.centerYAnchor.constraint(equalTo: buttonsContainer.centerYAnchor),
            saveButton.trailingAnchor.constraint(equalTo: buttonsContainer.trailingAnchor)
        ])
    }
    
    @objc private func selectTruthType() {
        selectedCardType = .truth
        updateTypeButtonsAppearance()
    }
    
    @objc private func selectDareType() {
        selectedCardType = .dare
        updateTypeButtonsAppearance()
    }
    
    private func updateTypeButtonsAppearance() {
        switch selectedCardType {
        case .truth:
            truthButton.backgroundColor = CardType.truth.color
            truthButton.setTitleColor(.white, for: .normal)
            dareButton.backgroundColor = .systemGray5
            dareButton.setTitleColor(.label, for: .normal)
        case .dare:
            dareButton.backgroundColor = CardType.dare.color
            dareButton.setTitleColor(.white, for: .normal)
            truthButton.backgroundColor = .systemGray5
            truthButton.setTitleColor(.label, for: .normal)
        }
    }
    
    @objc private func saveCard() {
        guard let text = cardTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            showAlert(title: "Ошибка", message: "Введите текст карточки")
            return
        }
        
        guard text.count <= 170 else {
            showAlert(title: "Ошибка", message: "Текст карточки не должен превышать 170 символов")
            return
        }
        
        let newCard = GameCard(text: text, type: selectedCardType)
        cards.append(newCard)
        
        hideCardCreationForm()
        updateCardsCount()
    }
    
    @objc private func cancelCardCreation() {
        hideCardCreationForm()
    }
    
    private func hideCardCreationForm() {
        cardCreationFormHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            self.cardCreationForm.isHidden = true
            self.cardTextView.text = ""
            self.characterCountLabel.text = "0/170"
            self.selectedCardType = .truth
            self.updateTypeButtonsAppearance()
        }
        
        view.endEditing(true)
    }
    
    @objc private func deleteCard(_ sender: UIButton) {
        let index = sender.tag
        guard index < cards.count else { return }
        
        cards.remove(at: index)
        updateCardsCount()
    }
    
    // MARK: - Collection Creation
    
    @objc private func didTapCreate() {
        createCollectionWithActionsAPI()
    }
    
    private func createCollectionWithActionsAPI() {
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
        
        CollectionsService.shared.createCollectionWithActions(
            name: name,
            description: description,
            actions: cards,
            imageUrl: nil
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("✅ Collection with actions created: \(response.message)")
                    self?.handleCreationSuccess()
                    
                case .failure(let error):
                    print("❌ Failed to create collection with actions: \(error)")
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
            message: "Подборка с карточками успешно создана",
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
    
    // MARK: - Keyboard Management
    
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
    
    // MARK: - Helper Methods
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate

extension AddViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView == descriptionTextView {
            placeholderLabel.isHidden = !textView.text.isEmpty
        } else if textView == cardTextView {
            let count = textView.text.count
            characterCountLabel.text = "\(count)/170"
            characterCountLabel.textColor = count > 170 ? .systemRed : .secondaryLabel
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == cardTextView {
            let currentText = textView.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
            return updatedText.count <= 170
        }
        return true
    }
}
