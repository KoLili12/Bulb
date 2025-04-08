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
        label.text = "Название подборки"
        label.numberOfLines = 2
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 30, weight: .bold)
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Описание подборки"
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    lazy var countQustionsLabel: UILabel = {
        let label = UILabel()
        label.text = "32 вопроса"
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    lazy var countWinLabel: UILabel = {
        let label = UILabel()
        label.text = "4542 раза пройдено"
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
    
    private var truthOrDareCollectionView: UICollectionView!
    private var selectionModeCollectionView: UICollectionView!
    
    private var selectedTruthOrDareModes: Set<TruthOrDareMode> = [.truth]
    private var selectedSelectionMode: SelectionMode = .fingers

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let backButton = createBackButton()
        let playButton = createPlayButton()
        
        setupTruthOrDareCollectionView()
        setupSelectionModeCollectionView()
        
        view.addSubview(sectionlable)
        view.addSubview(backButton)
        view.addSubview(descriptionLabel)
        view.addSubview(countQustionsLabel)
        view.addSubview(countWinLabel)
        view.addSubview(ChooseLabel)
        view.addSubview(truthOrDareCollectionView)
        view.addSubview(selectionModeCollectionView)
        view.addSubview(playButton)

        NSLayoutConstraint.activate([
            sectionlable.topAnchor.constraint(equalTo: view.topAnchor, constant: 56),
            sectionlable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            sectionlable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 104),
            backButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            backButton.widthAnchor.constraint(equalToConstant: 15),
            backButton.heightAnchor.constraint(equalToConstant: 15),
            
            descriptionLabel.topAnchor.constraint(equalTo: sectionlable.bottomAnchor, constant: 23),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            
            countQustionsLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 44),
            countQustionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            
            countWinLabel.topAnchor.constraint(equalTo: countQustionsLabel.bottomAnchor, constant: 6),
            countWinLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            
            ChooseLabel.topAnchor.constraint(equalTo: countWinLabel.bottomAnchor, constant: 23),
            ChooseLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            
            truthOrDareCollectionView.topAnchor.constraint(equalTo: ChooseLabel.bottomAnchor, constant: 20),
            truthOrDareCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            truthOrDareCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            truthOrDareCollectionView.heightAnchor.constraint(equalToConstant: 150), // Такая же высота, как у второй строки
            
            selectionModeCollectionView.topAnchor.constraint(equalTo: truthOrDareCollectionView.bottomAnchor, constant: 20),
            selectionModeCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            selectionModeCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            selectionModeCollectionView.heightAnchor.constraint(equalToConstant: 150),
            
            playButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -82),
            playButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            playButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            playButton.heightAnchor.constraint(equalToConstant: 57)
        ])
    }
    
    private func setupTruthOrDareCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        truthOrDareCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        truthOrDareCollectionView.backgroundColor = .clear
        truthOrDareCollectionView.register(GameModeCell.self, forCellWithReuseIdentifier: "GameModeCell")
        truthOrDareCollectionView.delegate = self
        truthOrDareCollectionView.dataSource = self
        truthOrDareCollectionView.tag = 0
        truthOrDareCollectionView.isScrollEnabled = false
        truthOrDareCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupSelectionModeCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 13
        layout.minimumInteritemSpacing = 13
        
        selectionModeCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        selectionModeCollectionView.backgroundColor = .clear
        selectionModeCollectionView.register(GameModeCell.self, forCellWithReuseIdentifier: "GameModeCell")
        selectionModeCollectionView.delegate = self
        selectionModeCollectionView.dataSource = self
        selectionModeCollectionView.tag = 1
        selectionModeCollectionView.isScrollEnabled = false
        selectionModeCollectionView.translatesAutoresizingMaskIntoConstraints = false
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
        button.backgroundColor = UIColor.green
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
        if collectionView.tag == 0 {
            return TruthOrDareMode.allCases.count // 2
        } else {
            return SelectionMode.allCases.count // 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameModeCell", for: indexPath) as! GameModeCell
        
        if collectionView.tag == 0 {
            let mode = TruthOrDareMode.allCases[indexPath.item]
            let isSelected = selectedTruthOrDareModes.contains(mode)
            let imageName: String? = {
                switch mode {
                case .truth: return "truthIcon"
                case .dare: return "dareIcon"
                }
            }()
            let count: String? = {
                switch mode {
                case .truth: return "20"
                case .dare: return "12"
                }
            }()
            let showSeparator = indexPath.item == 0
            cell.configure(title: mode.rawValue, imageName: imageName, count: count, isSelected: isSelected, showSeparator: showSeparator, isTruthOrDare: true)
            
            if indexPath.item == 0 {
                cell.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else {
                cell.contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
        } else {
            let mode = SelectionMode.allCases[indexPath.item]
            let isSelected = mode == selectedSelectionMode
            let imageName: String? = {
                switch mode {
                case .wheel: return "wheelIcon"
                case .fingers: return "fingersIcon"
                }
            }()
            cell.configure(title: mode.rawValue, imageName: imageName, count: nil, isSelected: isSelected, showSeparator: false, isTruthOrDare: false)
            
            cell.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 0 {
            let mode = TruthOrDareMode.allCases[indexPath.item]
            if selectedTruthOrDareModes.contains(mode) {
                selectedTruthOrDareModes.remove(mode)
            } else {
                selectedTruthOrDareModes.insert(mode)
            }
            truthOrDareCollectionView.reloadData()
        } else {
            selectedSelectionMode = SelectionMode.allCases[indexPath.item]
            selectionModeCollectionView.reloadData()
        }
    }
}

extension DetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 0 {
            let width = collectionView.frame.width
            return CGSize(width: width, height: 75) // 150 / 2 = 75 для каждой ячейки
        } else {
            let width = (collectionView.frame.width - 13) / 2
            return CGSize(width: width, height: 150)
        }
    }
}
