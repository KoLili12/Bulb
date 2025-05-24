//
//  DetailViewController.swift
//  Bulb
//
//  Created by Николай Жирнов on 27.03.2025.
//

import UIKit

class DetailViewController: UIViewController {
    
    lazy var sectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Название подборки\nМОЖЕТ БЫТЬ БОЛЬШ..."
        label.numberOfLines = 2
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 30, weight: .bold)
        return label
    }()
    
    lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.text = "Ксения Собчак"
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    lazy var sampleCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var sampleCardLabel: UILabel = {
        let label = UILabel()
        label.text = "Самый ворущий вопрос для самого честного ответа от которого ВСЕ будут в шоке реально (но не факт)?..."
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    lazy var countQuestionsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "questionmark.app")?.withTintColor(.black)
        imageAttachment.bounds = CGRect(x: 0, y: -2, width: 14, height: 14) // Размер иконки соответствует тексту
        
        let attributedString = NSMutableAttributedString()
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        attributedString.append(NSAttributedString(string: " 132 карточки"))
        label.attributedText = attributedString
        
        return label
    }()
    
    lazy var countWinLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "gamecontroller.circle")?.withTintColor(.black)
        imageAttachment.bounds = CGRect(x: 0, y: -2, width: 14, height: 14) // Размер иконки соответствует тексту
        
        let attributedString = NSMutableAttributedString()
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        attributedString.append(NSAttributedString(string: " 43 542 раз пройдено"))
        label.attributedText = attributedString
        
        return label
    }()
    
    private lazy var chooseLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "Выберите режим:"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 19, weight: .semibold)
        return label
    }()
    
    private lazy var infoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "info.circle.fill"), for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapInfoButton), for: .touchUpInside)
        return button
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
        
        sampleCardView.addSubview(sampleCardLabel)
        
        view.addSubview(sectionLabel)
        view.addSubview(backButton)
        view.addSubview(authorLabel)
        view.addSubview(sampleCardView)
        view.addSubview(countQuestionsLabel)
        view.addSubview(countWinLabel)
        view.addSubview(chooseLabel)
        view.addSubview(infoButton)
        view.addSubview(truthOrDareCollectionView)
        view.addSubview(selectionModeCollectionView)
        view.addSubview(playButton)

        NSLayoutConstraint.activate([
            sectionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            sectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            sectionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            backButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            backButton.widthAnchor.constraint(equalToConstant: 15),
            backButton.heightAnchor.constraint(equalToConstant: 15),
            
            authorLabel.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 8),
            authorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            
            sampleCardView.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 16),
            sampleCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            sampleCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            
            sampleCardLabel.topAnchor.constraint(equalTo: sampleCardView.topAnchor, constant: 10),
            sampleCardLabel.leadingAnchor.constraint(equalTo: sampleCardView.leadingAnchor, constant: 10),
            sampleCardLabel.trailingAnchor.constraint(equalTo: sampleCardView.trailingAnchor, constant: -10),
            sampleCardLabel.bottomAnchor.constraint(equalTo: sampleCardView.bottomAnchor, constant: -10),
            
            countQuestionsLabel.topAnchor.constraint(equalTo: sampleCardView.bottomAnchor, constant: 16),
            countQuestionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            
            countWinLabel.topAnchor.constraint(equalTo: countQuestionsLabel.bottomAnchor, constant: 6),
            countWinLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            
            chooseLabel.topAnchor.constraint(equalTo: countWinLabel.bottomAnchor, constant: 24),
            chooseLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            
            infoButton.centerYAnchor.constraint(equalTo: chooseLabel.centerYAnchor),
            infoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            infoButton.widthAnchor.constraint(equalToConstant: 24),
            infoButton.heightAnchor.constraint(equalToConstant: 24),
            
            truthOrDareCollectionView.topAnchor.constraint(equalTo: chooseLabel.bottomAnchor, constant: 16),
            truthOrDareCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            truthOrDareCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            truthOrDareCollectionView.heightAnchor.constraint(equalToConstant: 150),
            
            selectionModeCollectionView.topAnchor.constraint(equalTo: truthOrDareCollectionView.bottomAnchor, constant: 16),
            selectionModeCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            selectionModeCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            selectionModeCollectionView.heightAnchor.constraint(equalToConstant: 150),
            
            playButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
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
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTabBackButton), for: .touchUpInside)
        return button
    }
    
    private func createPlayButton() -> UIButton {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setTitle("Играть", for: .normal)
        button.backgroundColor = UIColor.violetBulb
        button.layer.cornerRadius = 23
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTabPlayButton), for: .touchUpInside)
        return button
    }
    
    @objc private func didTabBackButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTabPlayButton() {
        // Проверяем, выбран ли хотя бы один режим (Правда или Действие)
        guard !selectedTruthOrDareModes.isEmpty else {
            // Если ни один режим не выбран, показываем предупреждение
            showAlert(message: "Пожалуйста, выберите режим (Правда или Действие)")
            return
        }
        
        // Если хотя бы один режим выбран, продолжаем запуск игры
        switch selectedSelectionMode {
        case .fingers:
            let gameVC = GameViewController()
            gameVC.setTruthOrDareModes(selectedTruthOrDareModes)
            gameVC.modalPresentationStyle = .fullScreen
            present(gameVC, animated: true)
            
        case .arrow:
            let arrowGameVC = ArrowGameViewController()
            arrowGameVC.setTruthOrDareModes(selectedTruthOrDareModes)
            arrowGameVC.modalPresentationStyle = .fullScreen
            present(arrowGameVC, animated: true)
        }
    }

    // Метод для показа алерта с сообщением
    private func showAlert(message: String) {
        let alertController = UIAlertController(
            title: "Внимание",
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func didTapInfoButton() {
        let alert = UIAlertController(
            title: "Информация",
            message: "Вы можете выбрать оба варианта (Правду и Действие)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
                case .truth: return "questionmark.text.page.fill"
                case .dare: return "figure.american.football"
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
                case .fingers: return "hand.tap"
                case .arrow: return "arrow.up.backward.circle"
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
