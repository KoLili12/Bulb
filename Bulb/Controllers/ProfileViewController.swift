//
//  ProfileViewController.swift
//  Bulb
//
//  Updated with real user data from API
//

import UIKit

// MARK: - Simple Model (keeping for collections)
struct PlaylistItem {
    let title: String
    let author: String
    let cardCount: Int
    let rating: String
    let imageName: String
}

class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    private var selectedPlaylistIndex = 0
    private var isEditingMode = false
    private var currentUser: User?
    private var userCollections: [Collection] = []
    
    // Моковые данные для избранного (пока нет API для избранного)
    private let favoritesData = [
        PlaylistItem(title: "Правда или действие", author: "Пользователь", cardCount: 32, rating: "4.7", imageName: "2"),
        PlaylistItem(title: "Вечеринка", author: "Пользователь", cardCount: 48, rating: "4.9", imageName: "1")
    ]
    
    // MARK: - UI Components
    private var mainScrollView: UIScrollView!
    private var contentStackView: UIStackView!
    private var profileImageView: UIImageView!
    private var usernameLabel: UILabel!
    private var userDescriptionLabel: UILabel!
    private var playlistSelector: UISegmentedControl!
    private var playlistCollectionView: UICollectionView!
    
    // Profile fields
    private var nameTextField: UITextField!
    private var surnameTextField: UITextField!
    private var emailTextField: UITextField!
    private var phoneTextField: UITextField!
    private var descriptionTextField: UITextField!
    private var editButton: UIButton!
    
    // Loading indicator
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupKeyboardObservers()
        loadUserProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Обновляем профиль при каждом появлении экрана
        loadUserProfile()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - User Profile Loading
    
    private func loadUserProfile() {
        guard AuthManager.shared.isLoggedIn else {
            print("❌ User not logged in")
            showLoginRequired()
            return
        }
        
        print("🔄 Loading user profile...")
        loadingIndicator.startAnimating()
        
        // Загружаем пользователя из локального хранилища
        if let user = UserService.shared.getCurrentUserFromStorage() {
            print("✅ User loaded successfully: \(user.name) \(user.surname)")
            currentUser = user
            updateUIWithUserData(user)
            loadUserCollections()
        } else {
            print("❌ Failed to load user data")
            loadingIndicator.stopAnimating()
            showLoginRequired()
        }
    }
    
    private func loadUserCollections() {
        UserService.shared.getUserCollections { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                
                switch result {
                case .success(let collections):
                    self?.userCollections = collections
                    print("✅ Loaded \(collections.count) user collections")
                    self?.updatePlaylistContent()
                    
                case .failure(let error):
                    print("❌ Failed to load user collections: \(error)")
                    self?.userCollections = []
                    self?.updatePlaylistContent()
                }
            }
        }
    }
    
    private func updateUIWithUserData(_ user: User) {
        // Обновляем заголовок профиля
        usernameLabel.text = "\(user.name) \(user.surname)"
        userDescriptionLabel.text = user.description ?? "Описание не указано"
        
        // Обновляем поля формы
        nameTextField.text = user.name
        surnameTextField.text = user.surname
        emailTextField.text = user.email
        phoneTextField.text = user.phone ?? ""
        descriptionTextField.text = user.description ?? ""
        
        // Обновляем изображение профиля (пока используем placeholder)
        profileImageView.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.2)
        
        // Добавляем инициалы на изображение
        let initials = "\(user.name.prefix(1))\(user.surname.prefix(1))".uppercased()
        profileImageView.layer.sublayers?.removeAll()
        
        let textLayer = CATextLayer()
        textLayer.string = initials
        textLayer.fontSize = 24
        textLayer.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        textLayer.foregroundColor = UIColor.systemPurple.cgColor
        textLayer.alignmentMode = .center
        textLayer.frame = profileImageView.bounds
        textLayer.contentsScale = UIScreen.main.scale
        profileImageView.layer.addSublayer(textLayer)
    }
    
    private func showLoginRequired() {
        let alert = UIAlertController(
            title: "Требуется вход",
            message: "Для просмотра профиля необходимо войти в аккаунт",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Войти", style: .default) { [weak self] _ in
            self?.showLogin()
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showLogin() {
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: true)
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        setupScrollView()
        setupProfileHeader()
        setupPlaylistsSection()
        setupProfileInfoSection()
        setupConstraints()
        setupTapGesture()
        updatePlaylistContent()
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
    
    private func setupScrollView() {
        mainScrollView = UIScrollView()
        mainScrollView.showsVerticalScrollIndicator = false
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainScrollView)
        
        contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = 24
        contentStackView.alignment = .fill
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.addSubview(contentStackView)
        
        // Добавляем loading indicator
        view.addSubview(loadingIndicator)
    }
    
    private func setupProfileHeader() {
        let headerContainer = UIView()
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Profile Image
        profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 50
        profileImageView.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.2)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Username
        usernameLabel = UILabel()
        usernameLabel.text = "Загрузка..."
        usernameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        usernameLabel.textAlignment = .center
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Description
        userDescriptionLabel = UILabel()
        userDescriptionLabel.text = "Загрузка профиля..."
        userDescriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        userDescriptionLabel.textColor = .secondaryLabel
        userDescriptionLabel.textAlignment = .center
        userDescriptionLabel.numberOfLines = 2
        userDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerContainer.addSubview(profileImageView)
        headerContainer.addSubview(usernameLabel)
        headerContainer.addSubview(userDescriptionLabel)
        
        NSLayoutConstraint.activate([
            headerContainer.heightAnchor.constraint(equalToConstant: 200),
            
            profileImageView.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            usernameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            usernameLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 20),
            usernameLabel.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -20),
            
            userDescriptionLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            userDescriptionLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 20),
            userDescriptionLabel.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -20)
        ])
        
        contentStackView.addArrangedSubview(headerContainer)
    }
    
    private func setupPlaylistsSection() {
        let playlistContainer = createSectionContainer()
        
        // Segmented Control
        playlistSelector = UISegmentedControl(items: ["Избранные", "Мои подборки"])
        playlistSelector.selectedSegmentIndex = 0
        playlistSelector.backgroundColor = UIColor.systemGray6
        playlistSelector.selectedSegmentTintColor = UIColor.systemPurple
        playlistSelector.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        playlistSelector.translatesAutoresizingMaskIntoConstraints = false
        playlistSelector.addTarget(self, action: #selector(playlistTypeChanged), for: .valueChanged)
        
        // Collection View
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        playlistCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        playlistCollectionView.backgroundColor = .clear
        playlistCollectionView.showsHorizontalScrollIndicator = false
        playlistCollectionView.register(SimplePlaylistCell.self, forCellWithReuseIdentifier: "PlaylistCell")
        playlistCollectionView.delegate = self
        playlistCollectionView.dataSource = self
        playlistCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        playlistContainer.addSubview(playlistSelector)
        playlistContainer.addSubview(playlistCollectionView)
        
        NSLayoutConstraint.activate([
            playlistContainer.heightAnchor.constraint(equalToConstant: 220),
            
            playlistSelector.topAnchor.constraint(equalTo: playlistContainer.topAnchor, constant: 20),
            playlistSelector.leadingAnchor.constraint(equalTo: playlistContainer.leadingAnchor, constant: 20),
            playlistSelector.trailingAnchor.constraint(equalTo: playlistContainer.trailingAnchor, constant: -20),
            playlistSelector.heightAnchor.constraint(equalToConstant: 32),
            
            playlistCollectionView.topAnchor.constraint(equalTo: playlistSelector.bottomAnchor, constant: 16),
            playlistCollectionView.leadingAnchor.constraint(equalTo: playlistContainer.leadingAnchor),
            playlistCollectionView.trailingAnchor.constraint(equalTo: playlistContainer.trailingAnchor),
            playlistCollectionView.bottomAnchor.constraint(equalTo: playlistContainer.bottomAnchor, constant: -20)
        ])
        
        contentStackView.addArrangedSubview(playlistContainer)
    }
    
    private func setupProfileInfoSection() {
        let profileContainer = createSectionContainer()
        
        let fieldsStackView = UIStackView()
        fieldsStackView.axis = .vertical
        fieldsStackView.spacing = 16
        fieldsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create text fields
        nameTextField = createTextField(placeholder: "Имя", text: "")
        surnameTextField = createTextField(placeholder: "Фамилия", text: "")
        emailTextField = createTextField(placeholder: "Email", text: "")
        phoneTextField = createTextField(placeholder: "Телефон", text: "")
        descriptionTextField = createTextField(placeholder: "Описание", text: "")
        
        // Add fields to stack
        fieldsStackView.addArrangedSubview(createFieldWithLabel("Имя:", nameTextField))
        fieldsStackView.addArrangedSubview(createFieldWithLabel("Фамилия:", surnameTextField))
        fieldsStackView.addArrangedSubview(createFieldWithLabel("Email:", emailTextField))
        fieldsStackView.addArrangedSubview(createFieldWithLabel("Телефон:", phoneTextField))
        fieldsStackView.addArrangedSubview(createFieldWithLabel("Описание:", descriptionTextField))
        
        // Edit Button
        editButton = UIButton(type: .system)
        editButton.setTitle("Редактировать профиль", for: .normal)
        editButton.setTitleColor(.white, for: .normal)
        editButton.backgroundColor = UIColor.systemPurple
        editButton.layer.cornerRadius = 12
        editButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        
        // Добавляем Return ко всем полям для скрытия клавиатуры
        for textField in [nameTextField, surnameTextField, emailTextField, phoneTextField, descriptionTextField] {
            textField?.addTarget(self, action: #selector(textFieldDidReturn), for: .editingDidEndOnExit)
            textField?.returnKeyType = .done
        }
        
        // Logout Button
        let logoutButton = UIButton(type: .system)
        logoutButton.setTitle("🚪 Выйти из аккаунта", for: .normal)
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.backgroundColor = UIColor.systemRed
        logoutButton.layer.cornerRadius = 12
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        
        profileContainer.addSubview(fieldsStackView)
        profileContainer.addSubview(editButton)
        profileContainer.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            fieldsStackView.topAnchor.constraint(equalTo: profileContainer.topAnchor, constant: 20),
            fieldsStackView.leadingAnchor.constraint(equalTo: profileContainer.leadingAnchor, constant: 20),
            fieldsStackView.trailingAnchor.constraint(equalTo: profileContainer.trailingAnchor, constant: -20),
            
            editButton.topAnchor.constraint(equalTo: fieldsStackView.bottomAnchor, constant: 24),
            editButton.centerXAnchor.constraint(equalTo: profileContainer.centerXAnchor),
            editButton.widthAnchor.constraint(equalToConstant: 200),
            editButton.heightAnchor.constraint(equalToConstant: 44),
            
            logoutButton.topAnchor.constraint(equalTo: editButton.bottomAnchor, constant: 16),
            logoutButton.centerXAnchor.constraint(equalTo: profileContainer.centerXAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 200),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.bottomAnchor.constraint(equalTo: profileContainer.bottomAnchor, constant: -20)
        ])
        
        contentStackView.addArrangedSubview(profileContainer)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: mainScrollView.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor, constant: -20),
            contentStackView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor, constant: -40),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Helper Methods
    private func createSectionContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 16
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }
    
    private func createTextField(placeholder: String, text: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.text = text
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.backgroundColor = UIColor.tertiarySystemBackground
        textField.layer.cornerRadius = 8
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.isEnabled = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return textField
    }
    
    private func createFieldWithLabel(_ labelText: String, _ textField: UITextField) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = labelText
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(label)
        container.addSubview(textField)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            textField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            textField.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func getCurrentPlaylistData() -> [Any] {
        if selectedPlaylistIndex == 0 {
            return favoritesData
        } else {
            return userCollections
        }
    }
    
    private func updatePlaylistContent() {
        playlistCollectionView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func textFieldDidReturn() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        mainScrollView.contentInset.bottom = keyboardHeight
        mainScrollView.scrollIndicatorInsets.bottom = keyboardHeight
        
        if let activeField = findFirstResponder() {
            let rect = activeField.convert(activeField.bounds, to: mainScrollView)
            mainScrollView.scrollRectToVisible(rect, animated: true)
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        mainScrollView.contentInset.bottom = 0
        mainScrollView.scrollIndicatorInsets.bottom = 0
    }
    
    private func findFirstResponder() -> UIView? {
        for textField in [nameTextField, surnameTextField, emailTextField, phoneTextField, descriptionTextField] {
            if textField?.isFirstResponder == true {
                return textField
            }
        }
        return nil
    }
    
    @objc private func playlistTypeChanged() {
        selectedPlaylistIndex = playlistSelector.selectedSegmentIndex
        updatePlaylistContent()
    }
    
    @objc private func editButtonTapped() {
        if isEditingMode {
            view.endEditing(true)
            saveProfileChanges()
        }
        
        isEditingMode.toggle()
        
        let textFields = [nameTextField, surnameTextField, emailTextField, phoneTextField, descriptionTextField]
        
        for textField in textFields {
            textField?.isEnabled = isEditingMode
            textField?.backgroundColor = isEditingMode ? .systemBackground : .tertiarySystemBackground
        }
        
        editButton.setTitle(isEditingMode ? "Сохранить изменения" : "Редактировать профиль", for: .normal)
        editButton.backgroundColor = isEditingMode ? .systemGreen : .systemPurple
    }
    
    private func saveProfileChanges() {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let surname = surnameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty, !surname.isEmpty, !email.isEmpty else {
            showAlert(title: "Ошибка", message: "Пожалуйста, заполните обязательные поля")
            return
        }
        
        let phone = phoneTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let description = descriptionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Сохраняем локально (временно)
        UserService.shared.updateProfileLocally(
            name: name,
            surname: surname,
            email: email,
            phone: phone?.isEmpty == true ? nil : phone,
            description: description?.isEmpty == true ? nil : description
        )
        
        // Обновляем UI
        usernameLabel.text = "\(name) \(surname)"
        userDescriptionLabel.text = description?.isEmpty == true ? "Описание не указано" : description
        
        // Обновляем инициалы
        let initials = "\(name.prefix(1))\(surname.prefix(1))".uppercased()
        if let textLayer = profileImageView.layer.sublayers?.first as? CATextLayer {
            textLayer.string = initials
        }
        
        showAlert(title: "Сохранено", message: "Все изменения успешно сохранены")
    }
    
    @objc private func logoutButtonTapped() {
        let alert = UIAlertController(
            title: "Выход",
            message: "Вы уверены, что хотите выйти из аккаунта?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive) { [weak self] _ in
            AuthManager.shared.logout()
            
            // Очищаем локальные данные пользователя
            UserDefaults.standard.removeObject(forKey: "user_name")
            UserDefaults.standard.removeObject(forKey: "user_surname")
            UserDefaults.standard.removeObject(forKey: "user_email")
            UserDefaults.standard.removeObject(forKey: "user_phone")
            UserDefaults.standard.removeObject(forKey: "user_description")
            
            // Возвращаемся к экрану логина
            let loginVC = LoginViewController()
            loginVC.modalPresentationStyle = .fullScreen
            self?.present(loginVC, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let data = getCurrentPlaylistData()
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaylistCell", for: indexPath) as! SimplePlaylistCell
        
        let data = getCurrentPlaylistData()
        
        if selectedPlaylistIndex == 0 {
            // Избранные (моковые данные)
            let item = data[indexPath.item] as! PlaylistItem
            cell.configureWithPlaylistItem(item)
        } else {
            // Коллекции пользователя (реальные данные)
            let collection = data[indexPath.item] as! Collection
            cell.configureWithCollection(collection)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = getCurrentPlaylistData()
        
        if selectedPlaylistIndex == 0 {
            // Избранные
            let item = data[indexPath.item] as! PlaylistItem
            showAlert(title: item.title, message: "Автор: \(item.author)\nКарточек: \(item.cardCount)\nРейтинг: \(item.rating)")
        } else {
            // Коллекции пользователя
            let collection = data[indexPath.item] as! Collection
            showAlert(title: collection.name, message: "Описание: \(collection.description)\nСоздано: \(collection.createdAt)")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 140)
    }
}

// MARK: - Updated Collection View Cell
class SimplePlaylistCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let ratingLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        contentView.layer.shadowOpacity = 0.1
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = UIColor.systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        authorLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        authorLabel.textColor = .secondaryLabel
        authorLabel.textAlignment = .center
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        ratingLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        ratingLabel.textColor = .systemOrange
        ratingLabel.textAlignment = .center
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(ratingLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            
            ratingLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 2),
            ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            ratingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            ratingLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // Для избранных (моковые данные)
    func configureWithPlaylistItem(_ item: PlaylistItem) {
        titleLabel.text = item.title
        authorLabel.text = item.author
        ratingLabel.text = "⭐ \(item.rating)"
        
        // Используем системную иконку как placeholder
        imageView.image = UIImage(systemName: "photo")
        imageView.tintColor = .systemGray4
    }
    
    // Для коллекций пользователя (реальные данные API)
    func configureWithCollection(_ collection: Collection) {
        titleLabel.text = collection.name
        authorLabel.text = "Мои"
        ratingLabel.text = "📄 \(collection.actions?.count ?? 0)"
        
        // Используем системную иконку как placeholder
        imageView.image = UIImage(systemName: "folder")
        imageView.tintColor = UIColor(hex: "84C500")
    }
}
