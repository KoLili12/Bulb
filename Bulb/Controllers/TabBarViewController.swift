//
//  TabBarViewController.swift
//  Bulb
//
//  Created by Николай Жирнов on 25.03.2025.
//

import UIKit

class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeViewController = HomeViewController()
        let profileViewController = ProfileViewController()
        let addViewController = AddViewController()
        let searchViewController = SearchViewController()
        
        
        homeViewController.tabBarItem = UITabBarItem(
            title: "Лента",
            image: UIImage(named: "HomeIcon"),
            selectedImage: nil
        )
        searchViewController.tabBarItem = UITabBarItem(
            title: "Поиск",
            image: UIImage(named: "SearchIcon"),
            selectedImage: nil
        )
        addViewController.tabBarItem = UITabBarItem(
            title: "Добавить",
            image: UIImage(named: "AddIcon"),
            selectedImage: nil
        )
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "Профиль",
            image: UIImage(named: "ProfileIcon"),
            selectedImage: nil
        )
        
        homeViewController.tabBarItem.imageInsets =  UIEdgeInsets(top: 5, left: 16, bottom: 15, right: 16)
        profileViewController.tabBarItem.imageInsets =  UIEdgeInsets(top: 5, left: 12, bottom: 15, right: 12)
        searchViewController.tabBarItem.imageInsets =  UIEdgeInsets(top: 5, left: 15, bottom: 15, right: 15)
        addViewController.tabBarItem.imageInsets =  UIEdgeInsets(top: 5, left: 15, bottom: 15, right: 15)
        
        UITabBar.appearance().tintColor = UIColor(named: "violetBulb")
        
        // Настройка стеклянного табара
        setupGlassTabBar()
        
        self.viewControllers = [
            homeViewController,
            searchViewController,
            addViewController,
            profileViewController
        ]
    }
    
    private func setupGlassTabBar() {
        // Удаляем предыдущие слои, если они есть
        for subview in tabBar.subviews where subview is UIVisualEffectView {
            subview.removeFromSuperview()
        }
        
        // Настраиваем основу таббара
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.isTranslucent = true
        
        // Создаем градиентный слой
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = tabBar.bounds
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0.1).cgColor,  // Очень прозрачный вверху
            UIColor.white.withAlphaComponent(0.7).cgColor   // Более плотный внизу
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        // Создаем эффект размытия с меньшей интенсивностью
        let blurEffect = UIBlurEffect(style: .extraLight) // Более легкий стиль размытия
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = tabBar.bounds
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        visualEffectView.alpha = 0.7 // Уменьшаем общую непрозрачность
        
        // Добавляем размытие и градиент
        tabBar.insertSubview(visualEffectView, at: 0)
        visualEffectView.layer.insertSublayer(gradientLayer, at: 0)
        
        // Конфигурируем внешний вид для iOS 15+
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Обновляем размеры и положение градиента
        for subview in tabBar.subviews where subview is UIVisualEffectView {
            subview.frame = tabBar.bounds
            if let gradientLayer = subview.layer.sublayers?.first as? CAGradientLayer {
                gradientLayer.frame = tabBar.bounds
            }
        }
        
        // Закругляем углы
        tabBar.layer.cornerRadius = 24
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tabBar.layer.masksToBounds = true
    }
}
