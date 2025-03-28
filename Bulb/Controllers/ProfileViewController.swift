//
//  ProfileViewController.swift
//  Bulb
//
//  Created by Николай Жирнов on 25.03.2025.
//

import UIKit

class ProfileViewController: UIViewController {
    
    // MARK: - UI Components
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.backgroundColor = UIColor(named: "violetBulb")?.withAlphaComponent(0.2)
        imageView.image = UIImage(named: "profilePlaceholder")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var cameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor(named: "violetBulb")
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(changeProfilePictureTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Максим Петров"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var userDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Эксперт по квизам и викторинам"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var statsView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Добавляем тень
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        
        return view
    }()
    
    // Stats components
    private lazy var quizzesCompletedLabel = createStatLabel(title: "Пройдено", value: "42")
    private lazy var createdQuizzesLabel = createStatLabel(title: "Создано", value: "12")
    private lazy var averageScoreLabel = createStatLabel(title: "Средний балл", value: "87%")
    
    // Оставляем только одну кнопку для редактирования
    
    private lazy var profileInfoSection: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Добавляем тень
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        
        return view
    }()
    
    // Profile info fields
    private lazy var nameField = createProfileField(title: "Имя", value: "Максим")
    private lazy var surnameField = createProfileField(title: "Фамилия", value: "Петров")
    private lazy var emailField = createProfileField(title: "Email", value: "max.petrov@example.com")
    private lazy var phoneField = createProfileField(title: "Телефон", value: "+7 (999) 123-45-67")
    
    private lazy var editModeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Редактировать профиль", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "violetBulb")
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(toggleEditMode), for: .touchUpInside)
        return button
    }()
    
    private lazy var saveChangesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сохранить изменения", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "violetBulb")
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveProfileChanges), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    // Editing state
    private var isEditingMode = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // Применяем стеклянный эффект к компонентам
        applyGlassEffect(to: statsView)
        applyGlassEffect(to: profileInfoSection)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Добавляем компоненты на экран
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(cameraButton)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(userDescriptionLabel)
        contentView.addSubview(statsView)
        // Убрали лишнюю кнопку
        contentView.addSubview(profileInfoSection)
        contentView.addSubview(editModeButton)
        contentView.addSubview(saveChangesButton)
        
        // Добавляем статистику на statsView
        statsView.addSubview(quizzesCompletedLabel)
        statsView.addSubview(createdQuizzesLabel)
        statsView.addSubview(averageScoreLabel)
        
        // Добавляем поля профиля
        profileInfoSection.addSubview(nameField.stackView)
        profileInfoSection.addSubview(surnameField.stackView)
        profileInfoSection.addSubview(emailField.stackView)
        profileInfoSection.addSubview(phoneField.stackView)
        
        // Устанавливаем констрейнты
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Аватар
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Кнопка камеры
            cameraButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 4),
            cameraButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 4),
            cameraButton.widthAnchor.constraint(equalToConstant: 30),
            cameraButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Имя пользователя
            usernameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            usernameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Описание пользователя
            userDescriptionLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            userDescriptionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            userDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            userDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Блок статистики
            statsView.topAnchor.constraint(equalTo: userDescriptionLabel.bottomAnchor, constant: 24),
            statsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            statsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
            statsView.heightAnchor.constraint(equalToConstant: 80),
            
            // Статистика внутри блока
            quizzesCompletedLabel.leadingAnchor.constraint(equalTo: statsView.leadingAnchor, constant: 20),
            quizzesCompletedLabel.centerYAnchor.constraint(equalTo: statsView.centerYAnchor),
            
            createdQuizzesLabel.centerXAnchor.constraint(equalTo: statsView.centerXAnchor),
            createdQuizzesLabel.centerYAnchor.constraint(equalTo: statsView.centerYAnchor),
            
            averageScoreLabel.trailingAnchor.constraint(equalTo: statsView.trailingAnchor, constant: -20),
            averageScoreLabel.centerYAnchor.constraint(equalTo: statsView.centerYAnchor),
            
            // Убрали лишнюю кнопку редактирования
            
            // Секция информации профиля
            profileInfoSection.topAnchor.constraint(equalTo: statsView.bottomAnchor, constant: 24),
            profileInfoSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            profileInfoSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
            
            // Поля профиля внутри секции
            nameField.stackView.topAnchor.constraint(equalTo: profileInfoSection.topAnchor, constant: 20),
            nameField.stackView.leadingAnchor.constraint(equalTo: profileInfoSection.leadingAnchor, constant: 20),
            nameField.stackView.trailingAnchor.constraint(equalTo: profileInfoSection.trailingAnchor, constant: -20),
            
            surnameField.stackView.topAnchor.constraint(equalTo: nameField.stackView.bottomAnchor, constant: 16),
            surnameField.stackView.leadingAnchor.constraint(equalTo: profileInfoSection.leadingAnchor, constant: 20),
            surnameField.stackView.trailingAnchor.constraint(equalTo: profileInfoSection.trailingAnchor, constant: -20),
            
            emailField.stackView.topAnchor.constraint(equalTo: surnameField.stackView.bottomAnchor, constant: 16),
            emailField.stackView.leadingAnchor.constraint(equalTo: profileInfoSection.leadingAnchor, constant: 20),
            emailField.stackView.trailingAnchor.constraint(equalTo: profileInfoSection.trailingAnchor, constant: -20),
            
            phoneField.stackView.topAnchor.constraint(equalTo: emailField.stackView.bottomAnchor, constant: 16),
            phoneField.stackView.leadingAnchor.constraint(equalTo: profileInfoSection.leadingAnchor, constant: 20),
            phoneField.stackView.trailingAnchor.constraint(equalTo: profileInfoSection.trailingAnchor, constant: -20),
            phoneField.stackView.bottomAnchor.constraint(equalTo: profileInfoSection.bottomAnchor, constant: -20),
            
            // Кнопка режима редактирования
            editModeButton.topAnchor.constraint(equalTo: profileInfoSection.bottomAnchor, constant: 24),
            editModeButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            editModeButton.widthAnchor.constraint(equalToConstant: 200),
            editModeButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Кнопка сохранения изменений
            saveChangesButton.topAnchor.constraint(equalTo: editModeButton.bottomAnchor, constant: 16),
            saveChangesButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            saveChangesButton.widthAnchor.constraint(equalToConstant: 200),
            saveChangesButton.heightAnchor.constraint(equalToConstant: 40),
            saveChangesButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    // MARK: - Helpers
    
    private func createStatLabel(title: String, value: String) -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        
        // Создаем атрибутный текст для комбинирования разных стилей
        let attributedString = NSMutableAttributedString()
        
        // Добавляем значение большим жирным шрифтом
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        let valueAttributedString = NSAttributedString(string: value + "\n", attributes: valueAttributes)
        attributedString.append(valueAttributedString)
        
        // Добавляем заголовок меньшим шрифтом
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: UIColor.darkGray
        ]
        let titleAttributedString = NSAttributedString(string: title, attributes: titleAttributes)
        attributedString.append(titleAttributedString)
        
        label.attributedText = attributedString
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }
    
    private func createProfileField(title: String, value: String) -> (stackView: UIStackView, titleLabel: UILabel, valueField: UITextField) {
        // Создаем подписи
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .darkGray
        
        // Создаем поле ввода или статичное поле
        let valueField = UITextField()
        valueField.text = value
        valueField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        valueField.isEnabled = false
        valueField.borderStyle = .none
        
        // Создаем разделительную линию
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // Создаем вертикальный стек для надписи и поля
        let stackView = UIStackView(arrangedSubviews: [titleLabel, valueField, separatorView])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return (stackView, titleLabel, valueField)
    }
    
    private func applyGlassEffect(to view: UIView) {
        // Создаем эффект размытия
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = 0.4 // Регулируем прозрачность
        
        // Создаем градиентный слой
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0.6).cgColor,
            UIColor.white.withAlphaComponent(0.3).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = view.layer.cornerRadius
        
        // Вставляем слои
        view.insertSubview(blurView, at: 0)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Делаем фон более прозрачным
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
    }
    
    // MARK: - Actions
    
    // Удалили лишний метод editProfileTapped
    
    @objc private func changeProfilePictureTapped() {
        // Показываем ActionSheet для выбора фото
        let actionSheet = UIAlertController(title: "Изменить фото профиля", message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Сделать фото", style: .default) { _ in
            // Логика для открытия камеры
            print("Camera would open")
        }
        
        let libraryAction = UIAlertAction(title: "Выбрать из галереи", style: .default) { _ in
            // Логика для открытия галереи
            print("Photo library would open")
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true)
    }
    
    @objc private func toggleEditMode() {
        isEditingMode = !isEditingMode
        
        // Обновляем состояние UI
        nameField.valueField.isEnabled = isEditingMode
        surnameField.valueField.isEnabled = isEditingMode
        emailField.valueField.isEnabled = isEditingMode
        phoneField.valueField.isEnabled = isEditingMode
        
        // Меняем стиль полей
        let borderStyle: UITextField.BorderStyle = isEditingMode ? .roundedRect : .none
        nameField.valueField.borderStyle = borderStyle
        surnameField.valueField.borderStyle = borderStyle
        emailField.valueField.borderStyle = borderStyle
        phoneField.valueField.borderStyle = borderStyle
        
        // Показываем/скрываем кнопку сохранения
        saveChangesButton.isHidden = !isEditingMode
        
        // Меняем текст кнопки
        editModeButton.setTitle(isEditingMode ? "Отменить редактирование" : "Режим редактирования", for: .normal)
        
        // Меняем фон кнопки
        if isEditingMode {
            editModeButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
            editModeButton.setTitleColor(.systemRed, for: .normal)
        } else {
            editModeButton.backgroundColor = UIColor(named: "violetBulb")?.withAlphaComponent(0.1)
            editModeButton.setTitleColor(UIColor(named: "violetBulb"), for: .normal)
        }
    }
    
    @objc private func saveProfileChanges() {
        // Сохраняем изменения (в реальном приложении здесь будет обращение к серверу)
        
        // Обновляем отображаемые данные
        usernameLabel.text = "\(nameField.valueField.text ?? "") \(surnameField.valueField.text ?? "")"
        
        // Выходим из режима редактирования
        toggleEditMode()
        
        // Показываем уведомление об успешном сохранении
        let alert = UIAlertController(title: "Успешно", message: "Данные профиля обновлены", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}
