//
//  RecipeDetailVC.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/28/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia
import Hero

class RecipeDetailVC: UIViewController {
    
    var recipe: Recipe? {
        didSet {
            recipeHeaderView.countryLabel.text = recipe?.country
            if let countryCode = recipe?.countryCode { recipeHeaderView.countryFlag.image = UIImage(named: countryCode) }
            
            recipeHeaderView.recipeNameLabel.text = recipe?.name
            recipeHeaderView.creatorNameLabel.text = "by \(recipe!.creator.username)"
            
            if let overallRating = recipe?.overallRating {
                recipeHeaderView.starsImageView.image = starsImageForRating(overallRating.round(nearest: 0.5))
            } else {
                recipeHeaderView.starsImageView.isHidden = true
                recipeHeaderView.numberOfRatingsLabel.text = "No Ratings"
            }
            
            recipeHeaderView.favoriteButton.setImage(recipe?.hasFavorited == true ? #imageLiteral(resourceName: "favoriteButtonSelected") : #imageLiteral(resourceName: "favoriteButton"), for: .normal)
            
            if let ratings = recipe?.ratings {
                let text = "(\(ratings.count))"
                recipeHeaderView.numberOfRatingsLabel.text = text
            }
        }
    }
    
    let topView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        return button
    }()
    
    lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        return button
    }()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    let containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    let recipeHeaderView = RecipeHeaderView()
    
    lazy var menuBar: MenuBar = {
        let menuBar = MenuBar()
        menuBar.recipeDetailVC = self
        return menuBar
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(AboutCell.self, forCellWithReuseIdentifier: "aboutCell")
        collectionView.register(IngredientsCell.self, forCellWithReuseIdentifier: "ingredientsCell")
        collectionView.register(DirectionsCell.self, forCellWithReuseIdentifier: "directionsCell")
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var cookButton: UIButton = {
        let button = UIButton(type: .system)
        
        return button
    }()
    
    lazy var askButton: UIButton = {
        let button = UIButton(type: .system)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        recipeHeaderView.heroID = "recipeHeaderView"
        setUpViews()
    }
    
    var viewIsDark = Bool()
    
    func makeViewDark() {
        navigationController?.navigationBar.barStyle = UIBarStyle.black
        navigationController?.navigationBar.isHidden = true
        viewIsDark = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func makeViewLight() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = UIBarStyle.default
        viewIsDark = false
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        if viewIsDark {
            return .lightContent
        } else {
            return .default
        }
    }
    
    func setUpViews() {
        /*  topView
                backButton
                shareButton
            scrollView
                containerView
                    recipeHeaderView
                    menuBar
                    collectionView
            bottomView
                cookButton
                askButton
         */
        self.view.sv(topView, recipeHeaderView)
        self.view.backgroundColor = .red
        self.navigationController?.navigationBar.isTranslucent = false
        
        let margin = adaptConstant(18)
        
        topView.top(0).left(0).right(0).height(adaptConstant(79))
        
        recipeHeaderView.top(0).left(0).right(0).height(400)
        recipeHeaderView.photoImageView.top(0).left(0).right(0).height(adaptConstant(245))
        
        recipeHeaderView.countryFlag.left(margin)
        recipeHeaderView.countryFlag.Top == recipeHeaderView.photoImageView.Bottom + adaptConstant(16)
        recipeHeaderView.countryLabel.Left == recipeHeaderView.countryFlag.Right + adaptConstant(4)
        recipeHeaderView.countryLabel.CenterY == recipeHeaderView.countryFlag.CenterY
        
        recipeHeaderView.recipeNameLabel.left(margin).right(margin)
        recipeHeaderView.recipeNameLabel.Top == recipeHeaderView.countryFlag.Bottom
        
        recipeHeaderView.creatorNameLabel.left(margin)
        recipeHeaderView.creatorNameLabel.Top == recipeHeaderView.recipeNameLabel.Bottom
        
        recipeHeaderView.favoriteButton.right(adaptConstant(20))
        recipeHeaderView.favoriteButton.CenterY == recipeHeaderView.photoImageView.Bottom
        
        recipeHeaderView.numberOfRatingsLabel.right(margin)
        recipeHeaderView.starsImageView.CenterY == recipeHeaderView.creatorNameLabel.CenterY
        recipeHeaderView.numberOfRatingsLabel.CenterY == recipeHeaderView.creatorNameLabel.CenterY
        recipeHeaderView.starsImageView.Right == recipeHeaderView.numberOfRatingsLabel.Left - adaptConstant(4)
        
        recipeHeaderView.creatorNameLabel.bottom(adaptConstant(16))
        
        makeViewDark()
        //        makeViewLight()
    }
    
    override func viewDidLayoutSubviews() {
        let gradient = CAGradientLayer()
        
        gradient.frame = topView.bounds
        let colorOne = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        let colorTwo = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        gradient.colors = [colorOne.cgColor, colorTwo]
        
        topView.layer.insertSublayer(gradient, at: 0)
//        topView.backgroundColor = .clear
    }
}
