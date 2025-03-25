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
        
        
        homeViewController.tabBarItem = UITabBarItem(
            title: "Лента",
            image: UIImage(named: "HomeIcon"),
            selectedImage: nil
        )
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "Профиль",
            image: UIImage(named: "ProfileIcon"),
            selectedImage: nil
        )
        
        homeViewController.tabBarItem.imageInsets =  UIEdgeInsets(top: 5, left: 15, bottom: 15, right: 15)
        profileViewController.tabBarItem.imageInsets =  UIEdgeInsets(top: 1, left: 10, bottom: 15, right: 10)
        
        UITabBar.appearance().tintColor = UIColor(named: "violetBulb")
        self.viewControllers = [homeViewController, profileViewController]
    }
}
