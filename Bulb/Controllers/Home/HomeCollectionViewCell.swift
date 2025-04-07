import UIKit
import CHGlassmorphismView

class HomeCollectionViewCell: UICollectionViewCell {
    
    private let glassView = CHGlassmorphismView()
    
    lazy var nameTaskLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 8, weight: .medium)
        label.textColor = .white
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
        
        setupShadow()
        contentView.addSubview(imageSelectionView)
        
        // Настройка glassView только для нижней части
        glassView.setTheme(theme: .light)
        glassView.setBlurDensity(with: 0.8)
        glassView.setCornerRadius(0)
        glassView.alpha = 0.9
        glassView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(glassView)
    
        
        // Добавляем метки поверх glassView
        contentView.addSubview(nameTaskLabel)
        contentView.addSubview(authorLabel)
        
        
        NSLayoutConstraint.activate([
            // Изображение занимает всю карточку
            imageSelectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageSelectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageSelectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageSelectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Стеклянный эффект только в нижней части (~80px)
            glassView.heightAnchor.constraint(equalToConstant: 80),
            glassView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            glassView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            glassView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Метки текста располагаются над всеми элементами
            authorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            nameTaskLabel.bottomAnchor.constraint(equalTo: authorLabel.topAnchor, constant: -8),
            nameTaskLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTaskLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.4
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath
        
        // Создаем маску для скругления только нижних углов glassView
        let path = UIBezierPath(
            roundedRect: glassView.bounds,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 20, height: 20)
        )
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        glassView.layer.mask = maskLayer
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
