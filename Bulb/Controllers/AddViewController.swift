//
//  AddViewController.swift
//  Bulb
//
//  Created by Николай Жирнов on 25.03.2025.
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
    private var isCreatingCard = false
    private var selectedCardType: CardType = .truth
    
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
    
    // MARK: - Collection Info Section
    
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
    
    // MARK: - Cards Section
    
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
    
    // MARK: - Card Creation Form
    
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
    
    private lazy var formTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая карточка"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var cardTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 12
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var cardTextPlaceholder: UILabel = {
        let label = UILabel()
        label.text = "Введите текст карточки..."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .placeholderText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var characterCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/170"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8) // Добавим фон для видимости
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var cardTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "Тип карточки:"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var cardTypeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var formButtonsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var cancelCardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отмена", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelCardCreation), for: .touchUpInside)
        return button
    }()
    
    private lazy var saveCardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveCard), for: .touchUpInside)
        return button
    }()
    
    private lazy var cardsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Location Tag Section
    
    private lazy var locationTagSection: UIView = {
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
    
    private lazy var locationTagLabel: UILabel = {
        let label = UILabel()
        label.text = "Где играть?"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var locationTagStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Image Section
    
    private lazy var imageSection: UIView = {
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
    
    private lazy var imageLabel: UILabel = {
        let label = UILabel()
        label.text = "Обложка"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Выбрать изображение", for: .normal)
        button.setImage(UIImage(systemName: "photo"), for: .normal)
        button.tintColor = .systemBlue
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapAddImage), for: .touchUpInside)
        return button
    }()
    
    private lazy var selectedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Create Button
    
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
    
    // Dynamic constraint for card creation form
    private var cardCreationFormHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLocationTags()
        setupCardTypeTags()
        setupTextViewDelegates()
        setupTapGesture()
        setupKeyboardObservers()
        updateCardsCount()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(collectionInfoSection)
        contentView.addSubview(cardsSection)
        contentView.addSubview(locationTagSection)
        contentView.addSubview(imageSection)
        contentView.addSubview(createButton)
        
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
        
        // Card Creation Form
        cardCreationForm.addSubview(formTitleLabel)
        cardCreationForm.addSubview(cardTextView)
        cardCreationForm.addSubview(cardTextPlaceholder)
        cardCreationForm.addSubview(characterCountLabel)
        cardCreationForm.addSubview(cardTypeLabel)
        cardCreationForm.addSubview(cardTypeStackView)
        cardCreationForm.addSubview(formButtonsStack)
        
        formButtonsStack.addArrangedSubview(cancelCardButton)
        formButtonsStack.addArrangedSubview(saveCardButton)
        
        // Location Tag Section
        locationTagSection.addSubview(locationTagLabel)
        locationTagSection.addSubview(locationTagStackView)
        
        // Image Section
        imageSection.addSubview(imageLabel)
        imageSection.addSubview(addImageButton)
        imageSection.addSubview(selectedImageView)
        
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
            
            // Location Tag Section
            locationTagSection.topAnchor.constraint(equalTo: cardsSection.bottomAnchor, constant: 20),
            locationTagSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            locationTagSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            locationTagLabel.topAnchor.constraint(equalTo: locationTagSection.topAnchor, constant: 20),
            locationTagLabel.leadingAnchor.constraint(equalTo: locationTagSection.leadingAnchor, constant: 20),
            
            locationTagStackView.topAnchor.constraint(equalTo: locationTagLabel.bottomAnchor, constant: 16),
            locationTagStackView.leadingAnchor.constraint(equalTo: locationTagSection.leadingAnchor, constant: 20),
            locationTagStackView.trailingAnchor.constraint(equalTo: locationTagSection.trailingAnchor, constant: -20),
            locationTagStackView.bottomAnchor.constraint(equalTo: locationTagSection.bottomAnchor, constant: -20),
            locationTagStackView.heightAnchor.constraint(equalToConstant: 50),
            
            // Image Section
            imageSection.topAnchor.constraint(equalTo: locationTagSection.bottomAnchor, constant: 20),
            imageSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            imageSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            imageLabel.topAnchor.constraint(equalTo: imageSection.topAnchor, constant: 20),
            imageLabel.leadingAnchor.constraint(equalTo: imageSection.leadingAnchor, constant: 20),
            
            addImageButton.topAnchor.constraint(equalTo: imageLabel.bottomAnchor, constant: 16),
            addImageButton.leadingAnchor.constraint(equalTo: imageSection.leadingAnchor, constant: 20),
            addImageButton.trailingAnchor.constraint(equalTo: imageSection.trailingAnchor, constant: -20),
            
            selectedImageView.topAnchor.constraint(equalTo: addImageButton.bottomAnchor, constant: 16),
            selectedImageView.centerXAnchor.constraint(equalTo: imageSection.centerXAnchor),
            selectedImageView.widthAnchor.constraint(equalToConstant: 200),
            selectedImageView.heightAnchor.constraint(equalToConstant: 120),
            selectedImageView.bottomAnchor.constraint(equalTo: imageSection.bottomAnchor, constant: -20),
            
            // Create Button
            createButton.topAnchor.constraint(equalTo: imageSection.bottomAnchor, constant: 30),
            createButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 56),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
        
        setupCardCreationFormConstraints()
    }
    
    private func setupCardCreationFormConstraints() {
        NSLayoutConstraint.activate([
            formTitleLabel.topAnchor.constraint(equalTo: cardCreationForm.topAnchor, constant: 16),
            formTitleLabel.leadingAnchor.constraint(equalTo: cardCreationForm.leadingAnchor, constant: 16),
            
            cardTextView.topAnchor.constraint(equalTo: formTitleLabel.bottomAnchor, constant: 12),
            cardTextView.leadingAnchor.constraint(equalTo: cardCreationForm.leadingAnchor, constant: 16),
            cardTextView.trailingAnchor.constraint(equalTo: cardCreationForm.trailingAnchor, constant: -16),
            cardTextView.heightAnchor.constraint(equalToConstant: 120),
            
            cardTextPlaceholder.topAnchor.constraint(equalTo: cardTextView.topAnchor, constant: 16),
            cardTextPlaceholder.leadingAnchor.constraint(equalTo: cardTextView.leadingAnchor, constant: 16),
            
            characterCountLabel.topAnchor.constraint(equalTo: cardTextView.bottomAnchor, constant: 6),
            characterCountLabel.trailingAnchor.constraint(equalTo: cardTextView.trailingAnchor, constant: -4),
            characterCountLabel.heightAnchor.constraint(equalToConstant: 16),
            
            cardTypeLabel.topAnchor.constraint(equalTo: characterCountLabel.bottomAnchor, constant: 12),
            cardTypeLabel.leadingAnchor.constraint(equalTo: cardCreationForm.leadingAnchor, constant: 16),
            
            cardTypeStackView.topAnchor.constraint(equalTo: cardTypeLabel.bottomAnchor, constant: 8),
            cardTypeStackView.leadingAnchor.constraint(equalTo: cardCreationForm.leadingAnchor, constant: 16),
            cardTypeStackView.trailingAnchor.constraint(equalTo: cardCreationForm.trailingAnchor, constant: -16),
            cardTypeStackView.heightAnchor.constraint(equalToConstant: 44),
            
            formButtonsStack.topAnchor.constraint(equalTo: cardTypeStackView.bottomAnchor, constant: 16),
            formButtonsStack.leadingAnchor.constraint(equalTo: cardCreationForm.leadingAnchor, constant: 16),
            formButtonsStack.trailingAnchor.constraint(equalTo: cardCreationForm.trailingAnchor, constant: -16),
            formButtonsStack.bottomAnchor.constraint(equalTo: cardCreationForm.bottomAnchor, constant: -16),
            formButtonsStack.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupLocationTags() {
        for tag in LocationTag.allCases {
            let button = createLocationTagButton(for: tag)
            locationTagStackView.addArrangedSubview(button)
        }
        
        // Select first tag by default
        if let firstButton = locationTagStackView.arrangedSubviews.first as? UIButton {
            updateLocationTagButton(firstButton, isSelected: true)
        }
    }
    
    private func setupCardTypeTags() {
        for cardType in CardType.allCases {
            let button = createCardTypeButton(for: cardType)
            cardTypeStackView.addArrangedSubview(button)
        }
        
        // Select first type by default
        if let firstButton = cardTypeStackView.arrangedSubviews.first as? UIButton {
            updateCardTypeButton(firstButton, isSelected: true)
        }
    }
    
    private func createLocationTagButton(for tag: LocationTag) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(tag.rawValue, for: .normal)
        button.setImage(UIImage(systemName: tag.icon), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 12
        button.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        button.tintColor = .secondaryLabel
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        button.addTarget(self, action: #selector(locationTagButtonTapped(_:)), for: .touchUpInside)
        button.tag = LocationTag.allCases.firstIndex(of: tag) ?? 0
        return button
    }
    
    private func createCardTypeButton(for cardType: CardType) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(cardType.rawValue, for: .normal)
        button.setImage(UIImage(systemName: cardType.icon), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        button.tintColor = .secondaryLabel
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 6)
        button.addTarget(self, action: #selector(cardTypeButtonTapped(_:)), for: .touchUpInside)
        button.tag = CardType.allCases.firstIndex(of: cardType) ?? 0
        return button
    }
    
    private func updateLocationTagButton(_ button: UIButton, isSelected: Bool) {
        UIView.animate(withDuration: 0.2) {
            if isSelected {
                button.backgroundColor = UIColor(named: "violetBulb")
                button.tintColor = .white
                button.setTitleColor(.white, for: .normal)
                button.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            } else {
                button.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
                button.tintColor = .secondaryLabel
                button.setTitleColor(.secondaryLabel, for: .normal)
                button.transform = .identity
            }
        }
    }
    
    private func updateCardTypeButton(_ button: UIButton, isSelected: Bool) {
        let cardType = CardType.allCases[button.tag]
        UIView.animate(withDuration: 0.2) {
            if isSelected {
                button.backgroundColor = cardType.color
                button.tintColor = .white
                button.setTitleColor(.white, for: .normal)
                button.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            } else {
                button.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
                button.tintColor = .secondaryLabel
                button.setTitleColor(.secondaryLabel, for: .normal)
                button.transform = .identity
            }
        }
    }
    
    private func setupTextViewDelegates() {
        descriptionTextView.delegate = self
        cardTextView.delegate = self
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
    
    private func showCardCreationForm() {
        guard !isCreatingCard else { return }
        
        isCreatingCard = true
        cardCreationForm.isHidden = false
        cardCreationFormHeightConstraint.constant = 300 // Увеличил высоту для счетчика
        
        // Убедимся что счетчик отображается
        characterCountLabel.isHidden = false
        updateCharacterCount()
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            self.view.layoutIfNeeded()
            self.addCardButton.alpha = 0.5
            self.addCardButton.isEnabled = false
        }) { _ in
            self.cardTextView.becomeFirstResponder()
        }
    }
    
    private func hideCardCreationForm() {
        guard isCreatingCard else { return }
        
        isCreatingCard = false
        cardCreationFormHeightConstraint.constant = 0
        
        cardTextView.text = ""
        cardTextPlaceholder.isHidden = false
        characterCountLabel.text = "0/170"
        characterCountLabel.textColor = .secondaryLabel
        
        selectedCardType = .truth
        if let firstButton = cardTypeStackView.arrangedSubviews.first as? UIButton {
            updateCardTypeButton(firstButton, isSelected: true)
        }
        for (index, button) in cardTypeStackView.arrangedSubviews.enumerated() {
            if let button = button as? UIButton {
                updateCardTypeButton(button, isSelected: index == 0)
            }
        }
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            self.view.layoutIfNeeded()
            self.addCardButton.alpha = 1.0
            self.addCardButton.isEnabled = true
        }) { _ in
            self.cardCreationForm.isHidden = true
        }
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
    
    @objc private func locationTagButtonTapped(_ sender: UIButton) {
        for (index, button) in locationTagStackView.arrangedSubviews.enumerated() {
            if let button = button as? UIButton {
                updateLocationTagButton(button, isSelected: index == sender.tag)
            }
        }
        
        selectedLocationTag = LocationTag.allCases[sender.tag]
    }
    
    @objc private func cardTypeButtonTapped(_ sender: UIButton) {
        for (index, button) in cardTypeStackView.arrangedSubviews.enumerated() {
            if let button = button as? UIButton {
                updateCardTypeButton(button, isSelected: index == sender.tag)
            }
        }
        
        selectedCardType = CardType.allCases[sender.tag]
    }
    
    @objc private func didTapAddCard() {
        showCardCreationForm()
    }
    
    @objc private func cancelCardCreation() {
        view.endEditing(true)
        hideCardCreationForm()
    }
    
    @objc private func saveCard() {
        guard let cardText = cardTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !cardText.isEmpty else {
            showAlert(message: "Пожалуйста, введите текст карточки")
            return
        }
        
        let newCard = GameCard(
            text: cardText,
            type: selectedCardType
        )
        
        cards.append(newCard)
        
        DispatchQueue.main.async { [weak self] in
            self?.updateCardsCount()
            self?.hideCardCreationForm()
        }
        
        view.endEditing(true)
    }
    
    @objc private func deleteCard(_ sender: UIButton) {
        let index = sender.tag
        guard index < cards.count else { return }
        
        cards.remove(at: index)
        updateCardsCount()
    }
    
    @objc private func didTapAddImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    @objc private func didTapCreate() {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            showAlert(message: "Пожалуйста, введите название подборки")
            return
        }
        
        if cards.isEmpty {
            showAlert(message: "Добавьте хотя бы одну карточку")
            return
        }
        
        showAlert(message: "Подборка '\(name)' успешно создана!") { [weak self] _ in
            self?.resetForm()
        }
    }
    
    private func resetForm() {
        nameTextField.text = ""
        descriptionTextView.text = ""
        selectedImageView.image = nil
        selectedImageView.isHidden = true
        placeholderLabel.isHidden = false
        cards.removeAll()
        updateCardsCount()
        hideCardCreationForm()
    }
    
    private func showAlert(message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate

extension AddViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        switch textView {
        case descriptionTextView:
            placeholderLabel.isHidden = !textView.text.isEmpty
        case cardTextView:
            cardTextPlaceholder.isHidden = !textView.text.isEmpty
            updateCharacterCount()
        default:
            break
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == cardTextView {
            let currentText = textView.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: text)
            return newText.count <= 170
        }
        return true
    }
    
    private func updateCharacterCount() {
        let count = cardTextView.text.count
        characterCountLabel.text = "\(count)/170"
        
        switch count {
        case 0...140:
            characterCountLabel.textColor = .secondaryLabel
        case 141...160:
            characterCountLabel.textColor = .systemOrange
        case 161...170:
            characterCountLabel.textColor = .systemRed
        default:
            characterCountLabel.textColor = .systemRed
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        switch textView {
        case descriptionTextView:
            placeholderLabel.isHidden = !textView.text.isEmpty
        case cardTextView:
            cardTextPlaceholder.isHidden = !textView.text.isEmpty
            updateCharacterCount()
        default:
            break
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        switch textView {
        case descriptionTextView:
            placeholderLabel.isHidden = !textView.text.isEmpty
        case cardTextView:
            cardTextPlaceholder.isHidden = !textView.text.isEmpty
        default:
            break
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension AddViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectedImageView.image = image
            selectedImageView.isHidden = false
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - UIColor Extension


