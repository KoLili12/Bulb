//
//  GameModeCell.swift
//  Bulb
//
//  Created by Николай Жирнов on 28.03.2025.
//

import UIKit

class GameModeCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let iconImageView = UIImageView()
    private let countLabel = UILabel()
    private let separatorView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.layer.cornerRadius = 25
        
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        countLabel.textAlignment = .right
        countLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        separatorView.backgroundColor = .gray
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(countLabel)
        contentView.addSubview(separatorView)
    }
    
    func configure(title: String, imageName: String?, count: String?, isSelected: Bool, showSeparator: Bool, isTruthOrDare: Bool) {
        titleLabel.text = title
        countLabel.text = count
        contentView.backgroundColor = isSelected ? UIColor(hex: "#5800CF") : .systemGray5
        
        titleLabel.textColor = isSelected ? .white : .black
        countLabel.textColor = isSelected ? .white : .black
        
        if let imageName = imageName {
            iconImageView.image = UIImage(systemName: imageName)
            iconImageView.tintColor = isSelected ? .white : .black
            iconImageView.isHidden = false
        } else {
            iconImageView.image = nil
            iconImageView.isHidden = true
        }
        
        separatorView.isHidden = !showSeparator
        
        // Удаляем старые constraints
        contentView.constraints.forEach { constraint in
            if constraint.firstItem === iconImageView || constraint.firstItem === titleLabel || constraint.firstItem === countLabel || constraint.firstItem === separatorView {
                constraint.isActive = false
            }
        }
        
        if isTruthOrDare {
            // Для TruthOrDare: увеличиваем иконку и добавляем отступы
            titleLabel.textAlignment = .left
            countLabel.textAlignment = .right
            
            NSLayoutConstraint.activate([
                iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20), // Увеличиваем отступ слева
                iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                iconImageView.widthAnchor.constraint(equalToConstant: 30), // Увеличиваем размер иконки
                iconImageView.heightAnchor.constraint(equalToConstant: 30),
                
                titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
                titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                
                countLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20), // Увеличиваем отступ справа
                countLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                
                separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                separatorView.heightAnchor.constraint(equalToConstant: 1)
            ])
        } else {
            // Для SelectionMode: текст центрирован и смещен вниз
            titleLabel.textAlignment = .center
            countLabel.isHidden = true
            iconImageView.isHidden = false
            
            NSLayoutConstraint.activate([
                iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -10),
                iconImageView.widthAnchor.constraint(equalToConstant: 40),
                iconImageView.heightAnchor.constraint(equalToConstant: 40),
                
                titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                
                separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                separatorView.heightAnchor.constraint(equalToConstant: 1)
            ])
        }
    }
}

