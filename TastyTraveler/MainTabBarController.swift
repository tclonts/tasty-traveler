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
    }
    
    let shadowView = UIView()
    

    func setUpViewControllers() {
        // Home
        let homeNavController = templateNavController(image: #imageLiteral(resourceName: "home"), selectedImage: #imageLiteral(resourceName: "homeSelected"), viewController: HomeVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
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
        
        if index == 0 {
            if let vc = viewController as? UINavigationController, let homeVC = vc.viewControllers[0] as? HomeVC {
                if homeVC.collectionView!.contentOffset.y > CGFloat(0) {
                    UIView.animate(withDuration: 0.3, animations: {
                        homeVC.collectionView?.contentOffset.y = 0
                    })
                }
            }
        }
        
        if index == 2 {
            let createRecipeVC = CreateRecipeVC()
            
            present(createRecipeVC, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
}
