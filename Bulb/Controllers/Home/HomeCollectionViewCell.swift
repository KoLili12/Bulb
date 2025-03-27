//
//  HomeCollectionViewCell.swift
//  Bulb
//
//  Created by Николай Жирнов on 27.03.2025.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemGray6
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
