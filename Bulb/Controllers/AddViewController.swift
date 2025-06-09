//
//  AddViewController.swift
//  Bulb
//
//  Updated to use the new API endpoint for creating collections with actions
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
    
    // MARK: - UI Components (keeping existing UI setup code)
    
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
    
    // ОБНОВЛЕННЫЙ: Лейбл с детальной статистикой карточек
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
    
    // MARK: - Setup Methods (keeping existing setup code)
    
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
    
    // MARK: - ОБНОВЛЕННЫЙ метод подсчета карточек с детальной статистикой
    
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
    
    // MARK: - ОБНОВЛЕННЫЙ API метод создания коллекции
    
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
        
        // ОБНОВЛЕНО: Используем новый метод API для создания коллекции с карточками
        CollectionsService.shared.createCollectionWithActions(
            name: name,
            description: description,
            actions: cards, // Передаем массив GameCard
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
    
    // MARK: - Card Creation Methods (keeping existing methods)
    
    @objc private func didTapAddCard() {
        showCardCreationFormView()
    }
    
    // [Keeping all existing card creation methods unchanged...]
    
    private func showCardCreationFormView() {
        cardCreationForm.isHidden = false
        setupCardCreationFormContent()
        
        cardCreationFormHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            self.view.layoutIfNeeded()
        })
        
        cardTextView.becomeFirstResponder()
    }
    
    // [Include all remaining existing methods for card creation, UI updates, etc...]
    
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
    
    // [Continue with all other existing methods...]
}
