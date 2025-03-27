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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 20
        
        // Сначала настраиваем градиент (чтобы он был позади надписей)
        setupShadow()
        
        contentView.addSubview(imageSelectionView)
        setupGradient()
        contentView.addSubview(nameTaskLabel)
        contentView.addSubview(authorLabel)
        
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
        
        // Создаем новый градиент с более выраженным фиолетовым оттенком
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor(red: 0.4, green: 0.3, blue: 0.5, alpha: 0.1).cgColor,  // Более яркий фиолетовый оттенок
            UIColor(red: 0.35, green: 0.25, blue: 0.45, alpha: 0.4).cgColor,
            UIColor(red: 0.3, green: 0.2, blue: 0.4, alpha: 0.7).cgColor,
            UIColor(red: 0.25, green: 0.15, blue: 0.35, alpha: 0.85).cgColor
        ]
        
        // Настраиваем расположение для более плавного и очевидного градиента
        gradientLayer.locations = [0.0, 0.4, 0.6, 0.8, 1.0]
        
        gradientLayer.cornerRadius = 20
        
        // Делаем градиент более заметным
        gradientLayer.opacity = 1.0
        
        // Направление градиента
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        // Важно: добавляем градиент ПОВЕРХ imageView
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
