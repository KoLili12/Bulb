//
//  HomeCollectionViewCell.swift
//  Bulb
//
//  Created by Николай Жирнов on 27.03.2025.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
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
        contentView.backgroundColor = .black
        contentView.layer.cornerRadius = 20
        
        contentView.addSubview(imageSelectionView)
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
