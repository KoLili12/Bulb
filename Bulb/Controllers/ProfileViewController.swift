//
//  ProfileViewController.swift
//  Bulb
//
//  Created by Николай Жирнов on 25.03.2025.
//

import UIKit

// MARK: - Simple Model
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
    
    private let favoritesData = [
        PlaylistItem(title: "Правда или действие", author: "Ксения Собчак", cardCount: 32, rating: "4.7", imageName: "2"),
        PlaylistItem(title: "Вечеринка", author: "PartyQueen", cardCount: 48, rating: "4.9", imageName: "1"),
        PlaylistItem(title: "Викторина о фильмах", author: "CinemaLover", cardCount: 67, rating: "4.6", imageName: "3")
    ]
    
    private let myCollectionsData = [
        PlaylistItem(title: "Моя первая подборка", author: "Максим Петров", cardCount: 15, rating: "4.2", imageName: "1"),
        PlaylistItem(title: "Для друзей", author: "Максим Петров", cardCount: 23, rating: "4.5", imageName: "2")
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
    private var editButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupKeyboardObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        // Добавляем жест для скрытия клавиатуры при тапе на пустое место
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
        usernameLabel.text = "Максим Петров"
        usernameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        usernameLabel.textAlignment = .center
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Description
        userDescriptionLabel = UILabel()
        userDescriptionLabel.text = "Эксперт по квизам и викторинам"
        userDescriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        userDescriptionLabel.textColor = .secondaryLabel
        userDescriptionLabel.textAlignment = .center
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
        nameTextField = createTextField(placeholder: "Имя", text: "Максим")
        surnameTextField = createTextField(placeholder: "Фамилия", text: "Петров")
        emailTextField = createTextField(placeholder: "Email", text: "max.petrov@example.com")
        phoneTextField = createTextField(placeholder: "Телефон", text: "+7 (999) 123-45-67")
        
        // Add fields to stack
        fieldsStackView.addArrangedSubview(createFieldWithLabel("Имя:", nameTextField))
        fieldsStackView.addArrangedSubview(createFieldWithLabel("Фамилия:", surnameTextField))
        fieldsStackView.addArrangedSubview(createFieldWithLabel("Email:", emailTextField))
        fieldsStackView.addArrangedSubview(createFieldWithLabel("Телефон:", phoneTextField))
        
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
        for textField in [nameTextField, surnameTextField, emailTextField, phoneTextField] {
            textField?.addTarget(self, action: #selector(textFieldDidReturn), for: .editingDidEndOnExit)
            textField?.returnKeyType = .done
        }
        
        profileContainer.addSubview(fieldsStackView)
        profileContainer.addSubview(editButton)
        
        NSLayoutConstraint.activate([
            fieldsStackView.topAnchor.constraint(equalTo: profileContainer.topAnchor, constant: 20),
            fieldsStackView.leadingAnchor.constraint(equalTo: profileContainer.leadingAnchor, constant: 20),
            fieldsStackView.trailingAnchor.constraint(equalTo: profileContainer.trailingAnchor, constant: -20),
            
            editButton.topAnchor.constraint(equalTo: fieldsStackView.bottomAnchor, constant: 24),
            editButton.centerXAnchor.constraint(equalTo: profileContainer.centerXAnchor),
            editButton.widthAnchor.constraint(equalToConstant: 200),
            editButton.heightAnchor.constraint(equalToConstant: 44),
            editButton.bottomAnchor.constraint(equalTo: profileContainer.bottomAnchor, constant: -20)
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
            contentStackView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor, constant: -40)
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
    
    private func getCurrentPlaylistData() -> [PlaylistItem] {
        return selectedPlaylistIndex == 0 ? favoritesData : myCollectionsData
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
        
        // Добавляем отступ снизу для scroll view
        mainScrollView.contentInset.bottom = keyboardHeight
        mainScrollView.scrollIndicatorInsets.bottom = keyboardHeight
        
        // Прокручиваем к активному полю
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
        for textField in [nameTextField, surnameTextField, emailTextField, phoneTextField] {
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
            // Сначала скрываем клавиатуру
            view.endEditing(true)
        }
        
        isEditingMode.toggle()
        
        let textFields = [nameTextField, surnameTextField, emailTextField, phoneTextField]
        
        for textField in textFields {
            textField?.isEnabled = isEditingMode
            textField?.backgroundColor = isEditingMode ? .systemBackground : .tertiarySystemBackground
        }
        
        editButton.setTitle(isEditingMode ? "Сохранить изменения" : "Редактировать профиль", for: .normal)
        editButton.backgroundColor = isEditingMode ? .systemGreen : .systemPurple
        
        if !isEditingMode {
            // Update username
            if let name = nameTextField.text, let surname = surnameTextField.text {
                usernameLabel.text = "\(name) \(surname)"
            }
            
            let alert = UIAlertController(title: "Сохранено", message: "Все изменения успешно сохранены", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getCurrentPlaylistData().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaylistCell", for: indexPath) as! SimplePlaylistCell
        let item = getCurrentPlaylistData()[indexPath.item]
        cell.configure(with: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = getCurrentPlaylistData()[indexPath.item]
        
        let alert = UIAlertController(
            title: item.title,
            message: "Автор: \(item.author)\nКарточек: \(item.cardCount)\nРейтинг: \(item.rating)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 140)
    }
}

// MARK: - Simple Collection View Cell
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
    
    func configure(with item: PlaylistItem) {
        titleLabel.text = item.title
        authorLabel.text = item.author
        ratingLabel.text = "⭐ \(item.rating)"
        imageView.image = UIImage(named: item.imageName)
    }
}
