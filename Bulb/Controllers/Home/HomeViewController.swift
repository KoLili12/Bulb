import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    let mockImages = ["1", "2", "3", "1", "2", "3", "1", "2", "3", "1"]
    
    // Моковые данные для карточек
    let mockData = [
        (title: "Задания на 5+", author: "Oxxxymiron", description: "Описание все равно будет небольшим, его придется сильно ограничивать", rating: "4.9", cardCount: "43", locationTag: "Дома"),
        (title: "Правда или действие", author: "Ксения Собчак", description: "Самые откровенные вопросы для компании", rating: "4.7", cardCount: "32", locationTag: "Улица"),
        (title: "Игры на знакомство", author: "MaxPetrov", description: "Отличные вопросы для новой компании", rating: "4.8", cardCount: "25", locationTag: "Дома"),
        (title: "Вечеринка", author: "PartyQueen", description: "Зажигательные задания для веселой компании", rating: "4.9", cardCount: "48", locationTag: "Улица"),
        (title: "Викторина о фильмах", author: "CinemaLover", description: "Проверьте свои знания кинематографа", rating: "4.6", cardCount: "67", locationTag: "Дома"),
        (title: "Спорт и активность", author: "FitnessGuru", description: "Активные задания для спортивной компании", rating: "4.5", cardCount: "29", locationTag: "Улица"),
        (title: "Музыкальные вопросы", author: "MusicFan", description: "Для настоящих меломанов и ценителей", rating: "4.8", cardCount: "41", locationTag: "Дома"),
        (title: "Креативные задания", author: "CreativeArt", description: "Развиваем творческое мышление", rating: "4.7", cardCount: "35", locationTag: "Дома"),
        (title: "Романтика", author: "LoveExpert", description: "Для пар и романтических вечеров", rating: "4.9", cardCount: "22", locationTag: "Дома"),
        (title: "Детские игры", author: "KidsZone", description: "Безопасные и веселые задания для детей", rating: "4.8", cardCount: "56", locationTag: "Дома")
    ]
    
    // MARK: - UI Elements
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Сейчас в тренде"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16 // Вертикальный отступ между карточками
        layout.minimumInteritemSpacing = 17 // Горизонтальный отступ между карточками
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.scrollIndicatorInsets = collectionView.contentInset
        collectionView.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: "HomeCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UICollectionViewDataSource

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mockData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCell", for: indexPath) as! HomeCollectionViewCell
        
        let data = mockData[indexPath.item]
        let image = UIImage(named: mockImages[indexPath.item % mockImages.count])
        
        cell.configure(
            title: data.title,
            author: data.author,
            description: data.description,
            rating: data.rating,
            cardCount: data.cardCount,
            locationTag: data.locationTag,
            image: image
        )
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = mockData[indexPath.item]
        let viewController = DetailViewController()
        
        // Передаем данные в DetailViewController
        viewController.sectionLabel.text = data.title
        viewController.authorLabel.text = data.author
        viewController.sampleCardLabel.text = data.description
        
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Вычисляем размер для двух колонок
        let screenWidth = UIScreen.main.bounds.width
        let totalHorizontalSpacing: CGFloat = 16 + 17 + 16 // левый отступ + между карточками + правый отступ
        let availableWidth = screenWidth - totalHorizontalSpacing
        let cardWidth = availableWidth / 2
        
        // Пропорции как на втором изображении (более вытянутые)
        let cardHeight = cardWidth * 1.4 // соотношение примерно 1:1.4
        
        return CGSize(width: cardWidth, height: cardHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 17 // Горизонтальный отступ между карточками
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16 // Вертикальный отступ между карточками
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // Отступ от краев 16px, как указано в Figma
        return UIEdgeInsets(top: 0, left: 16, bottom: 100, right: 16) // Нижний отступ увеличен для TabBar
    }
}
