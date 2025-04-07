import UIKit
import CHGlassmorphismView

class HomeCollectionViewCell: UICollectionViewCell {
    
    private let glassView = CHGlassmorphismView()
    private let glassGradientLayer = CAGradientLayer()
    
    lazy var nameTaskLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var imageSelectionView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 20
        contentView.clipsToBounds = true
        
        setupShadow()
        contentView.addSubview(imageSelectionView)
        
        // Настройка градиента для стеклянного слоя
        glassGradientLayer.colors = [
            UIColor(hex: "84C500").withAlphaComponent(0).cgColor,
            UIColor(hex: "84C500").withAlphaComponent(0.2).cgColor
        ]
        glassGradientLayer.locations = [0.0, 1.0]
        glassGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        glassGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        // Настройка glassView с использованием методов библиотеки
        glassView.setTheme(theme: .light)
        glassView.setBlurDensity(with: 0.8)
        glassView.setCornerRadius(0)
        glassView.setDistance(10)
        glassView.alpha = 0.95
        glassView.translatesAutoresizingMaskIntoConstraints = false
        
        // ВАЖНО: явно задаем Frame
        glassView.frame = CGRect(x: 0, y: contentView.bounds.height - 78, width: contentView.bounds.width, height: 78)
        
        contentView.addSubview(glassView)
        
        // Добавляем градиентный слой в contentView
        contentView.layer.addSublayer(glassGradientLayer)
        
        // Добавляем метки поверх glassView
        glassView.addSubview(nameTaskLabel)
        glassView.addSubview(authorLabel)
        
        NSLayoutConstraint.activate([
            // Изображение занимает всю карточку
            imageSelectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageSelectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageSelectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageSelectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Стеклянный эффект только в нижней части (~78px)
            glassView.heightAnchor.constraint(equalToConstant: 78),
            glassView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            glassView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            glassView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Метки текста располагаются внутри glassView
            authorLabel.bottomAnchor.constraint(equalTo: glassView.bottomAnchor, constant: -15),
            authorLabel.leadingAnchor.constraint(equalTo: glassView.leadingAnchor, constant: 16),
            
            nameTaskLabel.bottomAnchor.constraint(equalTo: authorLabel.topAnchor, constant: -8),
            nameTaskLabel.leadingAnchor.constraint(equalTo: glassView.leadingAnchor, constant: 16),
            nameTaskLabel.trailingAnchor.constraint(equalTo: glassView.trailingAnchor, constant: -16)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.2
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Обновляем фрейм градиентного слоя
        glassGradientLayer.frame = CGRect(
            x: 0,
            y: contentView.bounds.height - 78,
            width: contentView.bounds.width,
            height: 78
        )
        
        print("Gradient layer frame: \(glassGradientLayer.frame)")
        print("Glass view bounds: \(glassView.bounds)")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        layer.shouldRasterize = false
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            layer.shouldRasterize = true
        }
    }
}

// Расширение для UIColor для удобства работы с hex-цветами
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
