//
//  HomeCollectionViewCell.swift
//  Bulb
//
//  Created by Николай Жирнов on 27.03.2025.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    private let gradientLayer = CAGradientLayer()
    
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
        contentView.layer.cornerRadius = 20
        
        // Сначала настраиваем градиент (чтобы он был позади надписей)
        setupShadow()
        
        contentView.addSubview(imageSelectionView)
        setupGradient()
        contentView.addSubview(nameTaskLabel)
        contentView.addSubview(authorLabel)
        setupBorder()
        
        NSLayoutConstraint.activate([
            imageSelectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageSelectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageSelectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageSelectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            authorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            nameTaskLabel.bottomAnchor.constraint(equalTo: authorLabel.topAnchor, constant: -8),
            nameTaskLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTaskLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
    }
    
    private func setupGradient() {
        // Удаляем существующий слой градиента, если он есть
        gradientLayer.removeFromSuperlayer()
        
        // Создаем максимально стеклянный градиент
        gradientLayer.colors = [
            UIColor.clear.cgColor,                                    // Полностью прозрачный сверху
            UIColor(white: 0.95, alpha: 0.05).cgColor,                // Очень легкий дымчатый
            UIColor(white: 0.9, alpha: 0.15).cgColor,                 // Почти прозрачный
            UIColor(white: 0.85, alpha: 0.3).cgColor                  // Легкая дымка внизу
        ]
        
        // Настраиваем расположение переходов для более естественного стеклянного эффекта
        gradientLayer.locations = [0.0, 0.75, 0.9, 1.0]
        
        // Закругляем углы градиента
        gradientLayer.cornerRadius = 20
        
        // Настраиваем направление градиента
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        // Максимальная прозрачность для стеклянного эффекта
        gradientLayer.opacity = 0.95
        
        // Добавляем гауссовое размытие для имитации матового стекла
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(3.0, forKey: "inputRadius")
        gradientLayer.filters = [filter!]
        
        // Добавляем градиент поверх изображения
        imageSelectionView.layer.addSublayer(gradientLayer)
    }
    
    private func setupShadow() {
        // Отключаем обрезку содержимого по границам слоя
        layer.masksToBounds = false
        
        // Основная тень - мягкая и рассеянная
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 15  // Большое значение для мягкой, размытой тени
        layer.shadowOpacity = 0.3
        
        // Добавляем небольшое свечение по контуру
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        
        // Улучшаем производительность
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    private func setupBorder() {
            // Настройка границы
            self.contentView.layer.borderWidth = 1.0
            self.contentView.layer.borderColor = UIColor.gray.cgColor
            
            // Если нужно скругленные углы
            self.contentView.layer.cornerRadius = 20
            self.contentView.layer.masksToBounds = true
        }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Обновление размера градиента при изменении размеров ячейки
        gradientLayer.frame = contentView.bounds
        // Обновляем путь тени при изменении размера
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Отключаем растеризацию при переиспользовании ячейки
        layer.shouldRasterize = false
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            // Включаем растеризацию снова, когда ячейка видна
            layer.shouldRasterize = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
