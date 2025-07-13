//
//  SearchViewController.swift
//  Bulb
//
//  Created by Николай Жирнов on 25.03.2025.
//

import UIKit

class SearchViewController: UIViewController {
    
    // MARK: - Properties
    
    private let categories = ["Все", "Викторины", "Игры", "Вечеринки", "Знакомства", "Отдых"]
    private let popularSearches = ["Игры на знакомство", "Кто я?", "Никогда я не...", "Правда или действие", "Викторина о фильмах", "Для компании"]
    private var selectedCategoryIndex: Int? = nil
    
    // MARK: - UI Components
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Искать подборки вопросов"
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .clear
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private lazy var categoryScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var categoryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var popularSearchesLabel: UILabel = {
        let label = UILabel()
        label.text = "Популярные запросы"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var popularCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(PopularSearchCell.self, forCellWithReuseIdentifier: "PopularSearchCell")
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupSearchBar()
        setupCategoryButtons()
        setupCollectionView()
        setupTapGesture()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(searchBar)
        view.addSubview(categoryScrollView)
        categoryScrollView.addSubview(categoryStackView)
        view.addSubview(popularSearchesLabel)
        view.addSubview(popularCollectionView)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            
            categoryScrollView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            categoryScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            categoryScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryScrollView.heightAnchor.constraint(equalToConstant: 44),
            
            categoryStackView.topAnchor.constraint(equalTo: categoryScrollView.topAnchor),
            categoryStackView.leadingAnchor.constraint(equalTo: categoryScrollView.leadingAnchor),
            categoryStackView.trailingAnchor.constraint(equalTo: categoryScrollView.trailingAnchor, constant: -28),
            categoryStackView.heightAnchor.constraint(equalTo: categoryScrollView.heightAnchor),
            
            popularSearchesLabel.topAnchor.constraint(equalTo: categoryScrollView.bottomAnchor, constant: 24),
            popularSearchesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            
            popularCollectionView.topAnchor.constraint(equalTo: popularSearchesLabel.bottomAnchor, constant: 16),
            popularCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            popularCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            popularCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
    }
    
    private func setupCategoryButtons() {
        for (index, category) in categories.enumerated() {
            let button = createCategoryButton(title: category, tag: index)
            categoryStackView.addArrangedSubview(button)
            
            // Не выбираем никакую категорию по умолчанию
            updateCategoryButton(button, isSelected: false)
        }
    }
    
    private func createCategoryButton(title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.layer.cornerRadius = 16
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.tag = tag
        
        updateCategoryButton(button, isSelected: false)
        
        button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    private func updateCategoryButton(_ button: UIButton, isSelected: Bool) {
        if isSelected {
            button.backgroundColor = UIColor(named: "violetBulb")
            button.setTitleColor(.white, for: .normal)
        } else {
            button.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
            button.setTitleColor(.darkGray, for: .normal)
        }
    }
    
    private func setupCollectionView() {
        popularCollectionView.delegate = self
        popularCollectionView.dataSource = self
    }
    
    private func setupTapGesture() {
        // Добавляем жест нажатия на пустое место для скрытия клавиатуры
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func categoryButtonTapped(_ sender: UIButton) {
        // Если нажата текущая выбранная категория, снимаем выбор
        if selectedCategoryIndex == sender.tag {
            if let currentButton = categoryStackView.arrangedSubviews[sender.tag] as? UIButton {
                updateCategoryButton(currentButton, isSelected: false)
            }
            selectedCategoryIndex = nil
            return
        }
        
        // Отменяем выбор предыдущей категории
        if let previousIndex = selectedCategoryIndex,
           let previousButton = categoryStackView.arrangedSubviews[previousIndex] as? UIButton {
            updateCategoryButton(previousButton, isSelected: false)
        }
        
        // Выбираем новую категорию
        selectedCategoryIndex = sender.tag
        updateCategoryButton(sender, isSelected: true)
        
        // Обновляем данные (в реальном приложении здесь был бы запрос к серверу)
        popularCollectionView.reloadData()
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if let searchText = searchBar.text, !searchText.isEmpty {
            // Здесь будет логика поиска (в реальном приложении)
            print("Поиск: \(searchText)")
        }
    }
    
    // Добавляем метод для скрытия клавиатуры при нажатии на кнопку "Отмена"
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // Показываем кнопку "Отмена" при активации поля поиска
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    // Скрываем кнопку "Отмена" при деактивации поля поиска
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popularSearches.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularSearchCell", for: indexPath) as! PopularSearchCell
        cell.configure(with: popularSearches[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedSearch = popularSearches[indexPath.item]
        print("Выбран поисковый запрос: \(selectedSearch)")
        
        // Здесь будет переход на экран результатов поиска
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - 15) / 2, height: 90)
    }
}

// MARK: - PopularSearchCell

class PopularSearchCell: UICollectionViewCell {
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Добавляем тень
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var searchIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.tintColor = UIColor(named: "violetBulb")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(searchIconView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            searchIconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            searchIconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            searchIconView.widthAnchor.constraint(equalToConstant: 20),
            searchIconView.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: searchIconView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Обновляем путь тени для правильного отображения
        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: containerView.layer.cornerRadius).cgPath
    }
}
