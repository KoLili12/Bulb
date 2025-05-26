import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    // Убираем моковые данные и заменяем на реальные
    private var collections: [Collection] = []
    private var isLoading = false
    
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
                    self?.collectionView.reloadData()
                    print("✅ Loaded \(fetchedCollections.count) collections")
                    
                case .failure(let error):
                    print("❌ Error loading collections: \(error)")
                    self?.showErrorAlert(error: error)
                    
                    // Если это первая загрузка и произошла ошибка, показываем пустое состояние
                    if self?.collections.isEmpty == true {
                        self?.showEmptyState()
                    }
                }
            }
        }
    }
    
    @objc private func refreshData() {
        loadTrendingCollections()
    }
    
    private func showEmptyState() {
        // Показываем пустое состояние если нет данных
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
        
        // Используем изображение из API или плейсхолдер
        let image: UIImage?
        if let imageUrl = collection.imageUrl, !imageUrl.isEmpty {
            // TODO: Загрузка изображения по URL (можно добавить позже)
            image = UIImage(systemName: "photo")
        } else {
            image = UIImage(systemName: "photo")
        }
        
        // Конвертируем данные API в формат для ячейки
        cell.configure(
            title: collection.name,
            author: "пользователь \(collection.userId)",
            description: collection.description,
            rating: calculateRating(playCount: collection.playCount),
            cardCount: "\(collection.actions?.count ?? 0)",
            locationTag: generateLocationTag(),
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
    
    private func generateLocationTag() -> String {
        return ["Дома", "Улица"].randomElement() ?? "Дома"
    }
}

// MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let collection = collections[indexPath.item]
        let viewController = DetailViewController()
        
        // Передаем реальные данные из API
        viewController.sectionLabel.text = collection.name
        viewController.authorLabel.text = "пользователь \(collection.userId)"
        viewController.sampleCardLabel.text = collection.description
        
        // Загружаем действия для этой коллекции
        CollectionsService.shared.getCollectionActions(id: collection.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let actions):
                    print("✅ Loaded \(actions.count) actions for collection \(collection.id)")
                    // Здесь можно передать действия в DetailViewController
                case .failure(let error):
                    print("❌ Error loading actions: \(error)")
                }
            }
        }
        
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
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
