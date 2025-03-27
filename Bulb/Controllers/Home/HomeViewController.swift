//
//  HomeViewController.swift
//  Bulb
//
//  Created by Николай Жирнов on 25.03.2025.
//

import UIKit

class HomeViewController: UIViewController {
    
    let mockImages = ["1", "2", "3", "1", "2", "3", "1", "2", "3", "1"]
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Сейчас в тренде"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: "HomeCell")
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        view.backgroundColor = .white
        
        view.addSubview(label)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            collectionView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 24),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor,  constant: 28),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28)
        ])
        
    }

}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCell", for: indexPath) as? HomeCollectionViewCell
        cell?.authorLabel.text = "John Doel"
        cell?.nameTaskLabel.text = "Task 1"
        cell?.imageSelectionView.image = UIImage(named: mockImages[indexPath.row])
        return cell ?? UICollectionViewCell()
    }
}

extension HomeViewController: UICollectionViewDelegate {
    
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 157, height: 197)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 20
        }
    
    
    
}
