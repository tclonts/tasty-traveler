//
//  MainTabBarController.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/7/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        
        setUpViewControllers()
        
        FirebaseController.shared.observeNotifications()
        FirebaseController.shared.observeMessages()
        FirebaseController.shared.observeUnreadMessagesCount()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTabBadge), name: Notification.Name("UpdateTabBadge"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showAchievement), name: Notification.Name("FirstRecipe"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(bronzeAchievement), name: Notification.Name("BronzeBadge"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(silverAchievement), name: Notification.Name("SilverBadge"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goldAchievement), name: Notification.Name("GoldBadge"), object: nil)



    }
    
    @objc func showAchievement() {
        let achievementVC = AchievementVC()
        achievementVC.modalPresentationStyle = .overCurrentContext
        self.present(achievementVC, animated: false) {
            achievementVC.show()
        }
    }
    
    @objc func bronzeAchievement() {
        let bronzeAchievementVC = BronzeAchievementVC()
        bronzeAchievementVC.modalPresentationStyle = .overCurrentContext
        self.present(bronzeAchievementVC, animated: false) {
            bronzeAchievementVC.show()
        }
    }
    
    @objc func silverAchievement() {
        let silverAchievementVC = SilverAchievementVC()
        silverAchievementVC.modalPresentationStyle = .overCurrentContext
        self.present(silverAchievementVC, animated: false) {
            silverAchievementVC.show()
        }
    }
    @objc func goldAchievement() {
        let goldAchievementVC = GoldAchievementVC()
        goldAchievementVC.modalPresentationStyle = .overCurrentContext
        self.present(goldAchievementVC, animated: false) {
            goldAchievementVC.show()
        }
    }
    
    @objc func updateTabBadge() {
        if FirebaseController.shared.unreadMessagesCount > 0 {
            self.tabBar.items![3].badgeValue = "\(FirebaseController.shared.unreadMessagesCount)"
        } else {
            self.tabBar.items![3].badgeValue = nil
        }
        
        if FirebaseController.shared.unreadNotificationsCount > 0 {
            self.tabBar.items![4].badgeValue = "\(FirebaseController.shared.unreadNotificationsCount)"
        } else {
            self.tabBar.items![4].badgeValue = nil
        }
    }
    
    let shadowView = UIView()
    
    func setUpViewControllers() {
        // Home
//        let homeNavController = templateNavController(image: #imageLiteral(resourceName: "home"), selectedImage: #imageLiteral(resourceName: "homeSelected"), viewController: HomeVC(collectionViewLayout: UICollectionViewFlowLayout()))
        let homeNavController = templateNavController(image: #imageLiteral(resourceName: "home"), selectedImage: #imageLiteral(resourceName: "homeSelected"), viewController: HomeVC())
        
        // Favorites
        let favoritesNavController = templateNavController(image: #imageLiteral(resourceName: "favorites"), selectedImage: #imageLiteral(resourceName: "favoritesSelected"), viewController: FavoritesVC())
        
        // Create Recipe
        let createRecipeNavController = templateNavController(image: #imageLiteral(resourceName: "createRecipe"), selectedImage: #imageLiteral(resourceName: "createRecipe"))
        
        // Questions
        let messagesNavController = templateNavController(image: #imageLiteral(resourceName: "messages"), selectedImage: #imageLiteral(resourceName: "messagesSelected"), viewController: MessagesVC())
        
        // Profile
        let profileNavController = templateNavController(image: #imageLiteral(resourceName: "profile"), selectedImage: #imageLiteral(resourceName: "profileSelected"), viewController: ProfileVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        tabBar.tintColor = UIColor(hexString: "CECECE")
        tabBar.isTranslucent = false
        tabBar.layer.borderWidth = 0.0
        tabBar.clipsToBounds = true
        
        shadowView.frame = tabBar.frame
        shadowView.backgroundColor = .white
        shadowView.layer.shadowOffset = CGSize(width: 0, height: -10)
        shadowView.layer.shadowRadius = 20
        shadowView.layer.shadowOpacity = 0.05
        shadowView.layer.shadowColor = UIColor.black.cgColor
        
        self.view.insertSubview(shadowView, belowSubview: tabBar)
        
        viewControllers = [homeNavController,
                           favoritesNavController,
                           createRecipeNavController,
                           messagesNavController,
                           profileNavController]
        
        guard let items = tabBar.items else { return }

        for item in items {
            item.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        }
    }
    
    fileprivate func templateNavController(image: UIImage, selectedImage: UIImage, viewController: UIViewController = UIViewController()) -> UINavigationController {
        let rootViewController = viewController
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = image
        navController.tabBarItem.selectedImage = selectedImage
        return navController
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.index(of: viewController)
        
        let currentIndex = tabBarController.selectedIndex
        
        if index == 0 && currentIndex == index {
            if let vc = viewController as? UINavigationController, let homeVC = vc.viewControllers[0] as? HomeVC {
                if homeVC.tableView!.contentOffset.y > CGFloat(0) {
                    UIView.animate(withDuration: 0.3, animations: {
                        homeVC.tableView?.contentOffset.y = 0
                    })
                }
            }
        }
        
        if let browsing = UserDefaults.standard.value(forKey: "isBrowsing") as? Bool, browsing, index != 0 {
            let accountAccessVC = AccountAccessVC()
            accountAccessVC.needAccount()
            present(accountAccessVC, animated: true, completion: nil)
            
            return false
        }
        
        if index == 2 {
            let createRecipeVC = CreateRecipeVC()
            //let recipeForm = RecipeForm()
            present(createRecipeVC, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
}
