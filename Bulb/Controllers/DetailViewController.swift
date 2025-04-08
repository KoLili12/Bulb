//
//  DetailViewController.swift
//  Bulb
//
//  Created by Николай Жирнов on 27.03.2025.
//

import UIKit

class DetailViewController: UIViewController {
    
    lazy var sectionlable: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 30, weight: .bold)
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    lazy var countQustionsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    lazy var countWinLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private lazy var ChooseLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "Выберите режим:"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 19, weight: .semibold)
        return label
    }()
    
    private var collectionView: UICollectionView!
    
    // Отслеживаем текущий выбранный режим
    private var selectedMode: GameMode = .random

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let backButton = createBackButton()
        let playButton = createPlayButton()
        

        setupCollectionView()
        
        view.addSubview(sectionlable)
        view.addSubview(backButton)
        view.addSubview(descriptionLabel)
        view.addSubview(countQustionsLabel)
        view.addSubview(countWinLabel)
        view.addSubview(ChooseLabel)
        view.addSubview(collectionView)
        view.addSubview(playButton)

        
        NSLayoutConstraint.activate([
            sectionlable.topAnchor.constraint(equalTo: view.topAnchor, constant: 56),
            sectionlable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 104),
            backButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            backButton.widthAnchor.constraint(equalToConstant: 15),
            backButton.heightAnchor.constraint(equalToConstant: 15),
            
            descriptionLabel.topAnchor.constraint(equalTo: sectionlable.bottomAnchor, constant: 23),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            
            countQustionsLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 44),
            countQustionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            
            countWinLabel.topAnchor.constraint(equalTo: countQustionsLabel.bottomAnchor, constant: 6),
            countWinLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            
            ChooseLabel.topAnchor.constraint(equalTo: countWinLabel.bottomAnchor, constant: 23),
            ChooseLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            
            
            collectionView.topAnchor.constraint(equalTo: ChooseLabel.topAnchor, constant: 50),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            collectionView.heightAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
            collectionView.bottomAnchor.constraint(equalTo: playButton.bottomAnchor, constant: -70),
            
            playButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -82),
            playButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            playButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            playButton.heightAnchor.constraint(equalToConstant: 57)
        ])
    }
    
    private func setupCollectionView() {
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 13
            layout.minimumInteritemSpacing = 20
            
            collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.backgroundColor = .clear
            collectionView.register(GameModeCell.self, forCellWithReuseIdentifier: "GameModeCell")
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            
        }
    
    private func createBackButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "backButton"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTabBackButton), for: .touchUpInside)
        return button
    }
    
    private func createPlayButton() -> UIButton {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setTitle("Играть", for: .normal)
        button.backgroundColor = UIColor(named: "violetBulb")
        button.layer.cornerRadius = 23
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTabPlayButton), for: .touchUpInside)
        return button
    }
    
    @objc private func didTabBackButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTabPlayButton() {
        let gameViewController = GameViewController()
        gameViewController.modalPresentationStyle = .fullScreen
        present(gameViewController, animated: true)
    }

}

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return GameMode.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameModeCell", for: indexPath) as! GameModeCell
        
        let mode = GameMode.allCases[indexPath.item]
        let isSelected = mode == selectedMode
        
        cell.configure(title: mode.rawValue, isSelected: isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMode = GameMode.allCases[indexPath.item]
        collectionView.reloadData()
    }
}

extension DetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 149, height: 149)
    }
}
