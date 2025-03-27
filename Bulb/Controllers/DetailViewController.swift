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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let backButton = createBackButton()
        

        view.addSubview(sectionlable)
        view.addSubview(backButton)
        view.addSubview(descriptionLabel)
        view.addSubview(countQustionsLabel)
        view.addSubview(countWinLabel)
        view.addSubview(ChooseLabel)
        
        NSLayoutConstraint.activate([
            sectionlable.topAnchor.constraint(equalTo: view.topAnchor, constant: 92),
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
        ])
    }
    
    private func createBackButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "backButton"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTabBackButton), for: .touchUpInside)
        return button
    }
    
    @objc private func didTabBackButton() {
        dismiss(animated: true)
    }

}
