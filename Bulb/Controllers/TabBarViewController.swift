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
        self.viewControllers = [
            homeViewController,
            searchViewController,
            addViewController,
            profileViewController
        ]
    }
}
