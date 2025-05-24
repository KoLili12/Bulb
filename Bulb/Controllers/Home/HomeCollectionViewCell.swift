import UIKit
import CHGlassmorphismView

class HomeCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var gradientOverlay: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let gradientLayer = CAGradientLayer()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.setImage(UIImage(systemName: "bookmark.fill"), for: .selected)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var contentContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold) // Немного уменьшил шрифт
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 8, weight: .medium) // Немного уменьшил
        label.textColor = .white.withAlphaComponent(0.7)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 8.5, weight: .regular) // Немного уменьшил
        label.textColor = .white.withAlphaComponent(0.8)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Контейнер для тегов
    private lazy var tagsContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 3 // Уменьшил отступ между тегами
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var ratingTag: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9, weight: .semibold)
        label.textColor = .white
        label.backgroundColor = UIColor(red: 0.76, green: 0.76, blue: 0.76, alpha: 0.3)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        // Добавляем внутренние отступы
        label.layer.masksToBounds = true
        return label
    }()
    
    private lazy var cardCountTag: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9, weight: .semibold)
        label.textColor = .white
        label.backgroundColor = UIColor(red: 0.76, green: 0.76, blue: 0.76, alpha: 0.3)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.masksToBounds = true
        return label
    }()
    
    private lazy var locationTag: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9, weight: .semibold)
        label.textColor = .white
        label.backgroundColor = UIColor(red: 0.76, green: 0.76, blue: 0.76, alpha: 0.3)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.masksToBounds = true
        return label
    }()
    
    private var isFavorite = false
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupCell() {
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        setupShadow()
        
        // Добавляем элементы в правильном порядке
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(gradientOverlay)
        contentView.addSubview(favoriteButton)
        contentView.addSubview(contentContainer)
        
        // Добавляем текстовые элементы в контейнер
        contentContainer.addSubview(titleLabel)
        contentContainer.addSubview(authorLabel)
        contentContainer.addSubview(descriptionLabel)
        contentContainer.addSubview(tagsContainer)
        
        // Добавляем теги в контейнер
        tagsContainer.addArrangedSubview(ratingTag)
        tagsContainer.addArrangedSubview(cardCountTag)
        tagsContainer.addArrangedSubview(locationTag)
        
        setupGradient()
        setupConstraints()
    }
    
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.3).cgColor,
            UIColor.black.withAlphaComponent(0.7).cgColor
        ]
        gradientLayer.locations = [0.0, 0.6, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientOverlay.layer.addSublayer(gradientLayer)
    }
    
    private func setupShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.15
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Фоновое изображение занимает всю карточку
            backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Градиентный оверлей
            gradientOverlay.topAnchor.constraint(equalTo: contentView.topAnchor),
            gradientOverlay.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientOverlay.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gradientOverlay.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Кнопка избранного в правом верхнем углу
            favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            favoriteButton.widthAnchor.constraint(equalToConstant: 22),
            favoriteButton.heightAnchor.constraint(equalToConstant: 22),
            
            // Контейнер для контента в нижней части с отступом 10px
            contentContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            contentContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            contentContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            contentContainer.topAnchor.constraint(greaterThanOrEqualTo: contentView.centerYAnchor),
            
            // Заголовок
            titleLabel.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            
            // Автор под заголовком
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 1),
            authorLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            
            // ТЕГИ ТЕПЕРЬ ИДУТ ПЕРЕД ОПИСАНИЕМ
            tagsContainer.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 4),
            tagsContainer.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            tagsContainer.trailingAnchor.constraint(lessThanOrEqualTo: contentContainer.trailingAnchor),
            
            // Описание под тегами
            descriptionLabel.topAnchor.constraint(equalTo: tagsContainer.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
            
            // Высота тегов и минимальная ширина с отступами
            ratingTag.heightAnchor.constraint(equalToConstant: 18),
            cardCountTag.heightAnchor.constraint(equalToConstant: 18),
            locationTag.heightAnchor.constraint(equalToConstant: 18),
            
            // Добавляем минимальную ширину для правильных отступов
            ratingTag.widthAnchor.constraint(greaterThanOrEqualToConstant: 50),
            cardCountTag.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),
            locationTag.widthAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Обновляем фрейм градиента
        gradientLayer.frame = gradientOverlay.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        layer.shouldRasterize = false
        isFavorite = false
        favoriteButton.isSelected = false
        
        // Очищаем текст
        titleLabel.text = nil
        authorLabel.text = nil
        descriptionLabel.text = nil
        ratingTag.text = nil
        cardCountTag.text = nil
        locationTag.text = nil
        backgroundImageView.image = nil
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            layer.shouldRasterize = true
        }
    }
    
    // MARK: - Actions
    
    @objc private func favoriteButtonTapped() {
        isFavorite.toggle()
        favoriteButton.isSelected = isFavorite
        
        // Анимация нажатия
        UIView.animate(withDuration: 0.1, animations: {
            self.favoriteButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.favoriteButton.transform = .identity
            }
        }
    }
    
    // MARK: - Configuration
    
    func configure(title: String, author: String, description: String, rating: String, cardCount: String, locationTag: String, image: UIImage?) {
        titleLabel.text = title
        authorLabel.text = "от \(author)"
        descriptionLabel.text = description
        
        // Убираем лишние пробелы, отступы теперь обеспечиваются constraints
        ratingTag.text = "⭐ \(rating)"
        cardCountTag.text = "📄 \(cardCount)"
        self.locationTag.text = locationTag
        
        // Устанавливаем цвет рейтинга в зависимости от значения
        if let ratingValue = Double(rating) {
            switch ratingValue {
            case 4.0...5.0:
                ratingTag.textColor = .systemGreen
            case 3.3..<4.0:
                ratingTag.textColor = .systemYellow
            case 1.0..<3.3:
                ratingTag.textColor = .systemRed
            default:
                ratingTag.textColor = .white
            }
        } else {
            ratingTag.textColor = .white
        }
        
        backgroundImageView.image = image
    }
}

// MARK: - Extensions для поддержки hex цветов

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
