import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    private var collections: [Collection] = []
    private var isLoading = false
    private var usersCache: [UInt: User] = [:] // Кэш пользователей
    
    // MARK: - UI Elements
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Сейчас в тренде"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 17
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.scrollIndicatorInsets = collectionView.contentInset
        collectionView.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: "HomeCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.refreshControl = refreshControl
        return collectionView
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadTrendingCollections()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Обновляем данные при каждом появлении экрана
        if !isLoading {
            loadTrendingCollections()
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Data Loading
    
    private func loadTrendingCollections() {
        guard !isLoading else { return }
        
        isLoading = true
        
        if collections.isEmpty {
            loadingIndicator.startAnimating()
        }
        
        CollectionsService.shared.getTrendingCollections(limit: 20) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.loadingIndicator.stopAnimating()
                self?.refreshControl.endRefreshing()
                
                switch result {
                case .success(let fetchedCollections):
                    self?.collections = fetchedCollections
                    self?.loadUsersForCollections(fetchedCollections)
                    print("✅ Loaded \(fetchedCollections.count) collections")
                    
                case .failure(let error):
                    print("❌ Error loading collections: \(error)")
                    self?.showErrorAlert(error: error)
                    
                    if self?.collections.isEmpty == true {
                        self?.showEmptyState()
                    }
                }
            }
        }
    }
    
    // Загружаем информацию о пользователях для коллекций
    private func loadUsersForCollections(_ collections: [Collection]) {
        let userIds = Array(Set(collections.map { $0.userId }))
        
        // Загружаем пользователей, которых еще нет в кэше
        for userId in userIds {
            if usersCache[userId] == nil {
                loadUser(id: userId)
            }
        }
        
        // Обновляем UI
        collectionView.reloadData()
    }
    
    private func loadUser(id: UInt) {
        guard usersCache[id] == nil else { return }
        
        UserService.shared.getUser(id: id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self?.usersCache[id] = user
                    print("✅ Loaded user: \(user.name) \(user.surname)")
                    self?.collectionView.reloadData()
                    
                case .failure(let error):
                    print("❌ Failed to load user \(id): \(error)")
                    let defaultUser = User(
                        id: id,
                        name: "Пользователь",
                        surname: "\(id)",
                        email: "user\(id)@example.com",
                        phone: nil,
                        imageUrl: nil,
                        description: nil,
                        createdAt: Date()
                    )
                    self?.usersCache[id] = defaultUser
                    self?.collectionView.reloadData()
                }
            }
        }
    }
    
    @objc private func refreshData() {
        usersCache.removeAll() // Очищаем кэш при обновлении
        loadTrendingCollections()
    }
    
    private func showEmptyState() {
        let emptyLabel = UILabel()
        emptyLabel.text = "Нет доступных подборок\nПроверьте подключение к интернету"
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 2
        emptyLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func showErrorAlert(error: NetworkError) {
        let alert = UIAlertController(
            title: "Ошибка загрузки",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadTrendingCollections()
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCell", for: indexPath) as! HomeCollectionViewCell
        
        let collection = collections[indexPath.item]
        
        // Получаем автора из кэша
        let authorName: String
        if let user = usersCache[collection.userId] {
            authorName = "\(user.name) \(user.surname)".trimmingCharacters(in: .whitespaces)
        } else {
            authorName = "Загрузка..."
        }
        
        // Используем изображение из API или плейсхолдер
        let image: UIImage?
        if let imageUrl = collection.imageUrl, !imageUrl.isEmpty {
            // TODO: Загрузка изображения по URL (можно добавить позже)
            image = UIImage(systemName: "photo")
        } else {
            image = UIImage(systemName: "photo")
        }
        
        // ОБНОВЛЕНО: Используем новые методы для подсчета карточек
        cell.configure(
            title: collection.name,
            author: authorName,
            description: collection.description,
            rating: calculateRating(playCount: collection.playCount),
            cardCount: "\(collection.totalCardsCount)", // Используем computed property
            locationTag: collection.cardTypeBreakdown, // Показываем breakdown типов карточек
            image: image
        )
        
        return cell
    }
    
    // Helper методы для генерации данных на основе API response
    private func calculateRating(playCount: Int) -> String {
        // Простая формула для генерации рейтинга на основе популярности
        let rating = min(5.0, max(3.0, 3.0 + Double(playCount) / 1000.0))
        return String(format: "%.1f", rating)
    }
}

// MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let collection = collections[indexPath.item]
        let viewController = DetailViewController()
        
        // Передаем реальные данные из API
        viewController.sectionLabel.text = collection.name
        
        // Устанавливаем автора
        if let user = usersCache[collection.userId] {
            viewController.authorLabel.text = "\(user.name) \(user.surname)"
        } else {
            viewController.authorLabel.text = "Автор: ID \(collection.userId)"
        }
        
        viewController.sampleCardLabel.text = collection.description
        
        // ОБНОВЛЕНО: Устанавливаем статистику карточек
        if let actions = collection.actions, !actions.isEmpty {
            // Если есть карточки, показываем пример первой карточки
            viewController.sampleCardLabel.text = actions.first?.text ?? collection.description
            
            // Обновляем счетчики в UI
            viewController.updateCountLabels(
                questionsCount: collection.totalCardsCount,
                truthCount: collection.truthCardsCount,
                dareCount: collection.dareCardsCount,
                playCount: collection.playCount
            )
        } else {
            // Если карточек нет, загружаем их
            loadActionsForDetail(collection: collection, detailVC: viewController)
        }
        
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
    
    private func loadActionsForDetail(collection: Collection, detailVC: DetailViewController) {
        CollectionsService.shared.getCollectionActions(id: collection.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let actions):
                    print("✅ Loaded \(actions.count) actions for collection \(collection.id)")
                    
                    if let firstAction = actions.first {
                        detailVC.sampleCardLabel.text = firstAction.text
                    }
                    
                    // Подсчитываем типы карточек
                    let truthCount = actions.filter { $0.type == "truth" }.count
                    let dareCount = actions.filter { $0.type == "dare" }.count
                    
                    detailVC.updateCountLabels(
                        questionsCount: actions.count,
                        truthCount: truthCount,
                        dareCount: dareCount,
                        playCount: collection.playCount
                    )
                    
                case .failure(let error):
                    print("❌ Error loading actions: \(error)")
                }
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let totalHorizontalSpacing: CGFloat = 16 + 17 + 16
        let availableWidth = screenWidth - totalHorizontalSpacing
        let cardWidth = availableWidth / 2
        let cardHeight = cardWidth * 1.4
        
        return CGSize(width: cardWidth, height: cardHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 17
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 100, right: 16)
    }
}
