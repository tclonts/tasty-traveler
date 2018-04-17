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
import AVKit

class RecipeDetailVC: UIViewController {
        
    var recipe: Recipe? {
        didSet {
            recipeHeaderView.countryLabel.text = "United States"//recipe?.country
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
    
    let topView: UIImageView = {
        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "topGradient")
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "backButton"), for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var backButtonNav: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "backButtonNav"), for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "shareButton"), for: .normal)
        return button
    }()
    
    lazy var shareButtonNav: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        
        let attributedText = NSAttributedString(string: "SHARE", attributes: [NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: 13)!,
                                                                             NSAttributedStringKey.foregroundColor: Color.darkGrayText])
        
        button.setImage(#imageLiteral(resourceName: "shareNav"), for: .normal)
        button.setAttributedTitle(attributedText, for: .normal)
        
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        
        return button
    }()
    
    lazy var favoriteButtonNav: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        
        let attributedText = NSAttributedString(string: "SAVE", attributes: [NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: 13)!,
                                                                             NSAttributedStringKey.foregroundColor: Color.darkGrayText])
        
        button.setImage(#imageLiteral(resourceName: "favoriteNav"), for: .normal)
        button.setAttributedTitle(attributedText, for: .normal)
        
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        
        return button
    }()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
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
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(AboutCell.self, forCellWithReuseIdentifier: "aboutCell")
        collectionView.register(IngredientsCell.self, forCellWithReuseIdentifier: "ingredientsCell")
        collectionView.register(DirectionsCell.self, forCellWithReuseIdentifier: "directionsCell")
        collectionView.backgroundColor = .white
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var cookButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setTitleColor(Color.primaryOrange, for: .normal)
        button.setTitleColor(Color.gray, for: .selected)
        button.setTitle("Cooked it!", for: .normal)
        button.setTitle("Cooked", for: .selected)
        return button
    }()
    
    lazy var askButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = Color.primaryOrange
        button.setTitle("Ask", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let margin = adaptConstant(18)
    var aboutCellScrollView: UIScrollView?
    var ingredientsCellTableView: UITableView?
    var directionsCellTableView: UITableView?
    
    var viewIsDark: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isHeroEnabled = true
        self.view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.alpha = 0
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false

        recipeHeaderView.heroID = "recipeHeaderView"
        
        setUpViews()
        applyHeroModifiers()
        
        viewIsDark = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        topView.topConstraint?.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    @objc func backButtonTapped() {
        self.hero_dismissViewController()
    }
    
    @objc func shareButtonTapped() {
        
    }
    
    @objc func favoriteButtonTapped() {
    }
    
    func showTopView() {
        self.topView.alpha = 0
        self.topView.isHidden = false
        viewIsDark = true
        
        UIView.animate(withDuration: 0.3, animations: {
            self.topView.alpha = 1
            self.navigationController?.navigationBar.alpha = 0
            self.recipeHeaderView.favoriteButton.alpha = 1
            self.setNeedsStatusBarAppearanceUpdate()
        }) { (complete) in
            self.navigationController?.navigationBar.isHidden = true
            self.viewIsDark = true
        }
    }
    
    func showNavBar() {
        self.navigationController?.navigationBar.alpha = 0
        self.navigationController?.navigationBar.isHidden = false
        viewIsDark = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.navigationController?.navigationBar.alpha = 1
            self.topView.alpha = 0
            self.recipeHeaderView.favoriteButton.alpha = 0
            self.setNeedsStatusBarAppearanceUpdate()
        }) { (complete) in
            self.topView.isHidden = true
            self.viewIsDark = false
        }
        
    }
    
    func playVideo() {
        if let videoURL = recipe?.videoURL {
            guard let url = URL(string: videoURL) else { return }
            let player = AVPlayer(url: url)
            
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            
            present(playerViewController, animated: true, completion: {
                playerViewController.player!.play()
            })
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let isDark = viewIsDark {
            if isDark {
                return .lightContent
            } else {
                return .default
            }
        } else {
            return .lightContent
        }
    }
    
    func applyHeroModifiers() {
        
    }
    
    func setUpViews() {
        
        self.view.sv(scrollView, topView, bottomView)
        self.view.backgroundColor = .white
        
        self.navigationController?.navigationBar.sv(backButtonNav, favoriteButtonNav, shareButtonNav)
        
        shareButtonNav.right(20)
        shareButtonNav.centerVertically()
        
        favoriteButtonNav.Right == shareButtonNav.Left - 30
        favoriteButtonNav.centerVertically()
        
        backButtonNav.left(20)
        backButtonNav.centerVertically()
        
        setUpScrollView()
        setUpTopView()
        setUpBottomView()
    }
    
    func setUpTopView() {
        topView.sv(backButton, shareButton)
        
        topView.top(-adaptConstant(79)).left(0).right(0).height(adaptConstant(79))
        
        backButton.left(20)
        backButton.centerVertically()
        
        shareButton.right(20)
        shareButton.centerVertically()
    }
    
    func setUpScrollView() {
        scrollView.delegate = self
        scrollView.top(0).left(0).right(0).Bottom == bottomView.Top
        
        scrollView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        
        scrollView.sv(
            containerView.sv(
                recipeHeaderView,
                menuBar,
                collectionView
            )
        )
        
        containerView.fillContainer()
        containerView.Width == scrollView.Width
        
        recipeHeaderView.top(0).left(0).right(0)
        recipeHeaderView.photoImageView.top(0).left(0).right(0)
        recipeHeaderView.photoImageView.Height == recipeHeaderView.photoImageView.Width * 0.75
        
        recipeHeaderView.countryFlag.left(margin)
        recipeHeaderView.countryFlag.Top == recipeHeaderView.photoImageView.Bottom + adaptConstant(16)
        recipeHeaderView.countryLabel.Left == recipeHeaderView.countryFlag.Right + adaptConstant(4)
        recipeHeaderView.countryLabel.CenterY == recipeHeaderView.countryFlag.CenterY
        
        recipeHeaderView.recipeNameLabel.left(margin).right(margin)
        recipeHeaderView.recipeNameLabel.Top == recipeHeaderView.countryFlag.Bottom + adaptConstant(12)
        
        recipeHeaderView.creatorNameLabel.left(margin)
        recipeHeaderView.creatorNameLabel.Top == recipeHeaderView.recipeNameLabel.Bottom + adaptConstant(12)
        
        recipeHeaderView.numberOfRatingsLabel.right(margin)
        recipeHeaderView.starsImageView.CenterY == recipeHeaderView.creatorNameLabel.CenterY
        recipeHeaderView.numberOfRatingsLabel.CenterY == recipeHeaderView.creatorNameLabel.CenterY
        recipeHeaderView.starsImageView.Right == recipeHeaderView.numberOfRatingsLabel.Left - adaptConstant(4)
        
        recipeHeaderView.creatorNameLabel.bottom(adaptConstant(16))
        
        recipeHeaderView.favoriteButton.right(adaptConstant(20))
        recipeHeaderView.favoriteButton.CenterY == recipeHeaderView.photoImageView.Bottom
        
        menuBar.left(0).right(0).height(adaptConstant(40))
        menuBar.Top == recipeHeaderView.Bottom + adaptConstant(12)
        
        collectionView.Top == menuBar.Bottom
        collectionView.left(0).right(0).bottom(0)
        // view - recipeheaderview height - navbar height - menu bar height - bottomview height
        let collectionViewHeight: CGFloat = self.view.frame.height - menuBar.frame.height - recipeHeaderView.frame.height - 64 - menuBar.frame.height - adaptConstant(45) - adaptConstant(45)
        collectionView.height(collectionViewHeight)
        
        
    }
    
    func setUpBottomView() {
        bottomView.bottom(0).left(0).right(0).height(adaptConstant(45))
        bottomView.width(self.view.frame.width)
        bottomView.sv(cookButton, askButton)
        
        cookButton.width(self.view.frame.width / 2)
        cookButton.left(0).top(0).bottom(0)
        
        askButton.width(self.view.frame.width / 2)
        askButton.right(0).top(0).bottom(0)
        
        bottomView.layer.shadowOffset = CGSize(width: 0, height: -5)
        bottomView.layer.shadowRadius = 25
        bottomView.layer.shadowOpacity = 0.1
    }
    
    var isInAboutCellScrollView = false
}

extension RecipeDetailVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func scrollToMenuIndex(_ menuIndex: Int) {
        let indexPath = IndexPath(item: menuIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("SCROLL")
        if scrollView == self.scrollView && aboutCellScrollView != nil {
            aboutCellScrollView!.isScrollEnabled = (self.scrollView.contentOffset.y >= (self.scrollView.contentSize.height - self.scrollView.frame.size.height))
            if let tableView = ingredientsCellTableView {
                if tableView.contentSize.height > tableView.frame.size.height {
                    ingredientsCellTableView?.isScrollEnabled = (self.scrollView.contentOffset.y >= (self.scrollView.contentSize.height - self.scrollView.frame.size.height))
                }
                
            }
            
        }

        if scrollView == self.aboutCellScrollView && aboutCellScrollView != nil {
            if scrollView.contentOffset.y < 0 { isInAboutCellScrollView = true }
            
            if isInAboutCellScrollView {
                scrollView.isScrollEnabled = true
                isInAboutCellScrollView = false
            } else {
                scrollView.isScrollEnabled = scrollView.contentOffset.y > 0
            }
            self.aboutCellScrollView!.isScrollEnabled = (aboutCellScrollView!.contentOffset.y > 0)
        }
        
        if scrollView == self.scrollView {
            if viewIsDark == nil { return }
            if scrollView.contentOffset.y >= recipeHeaderView.photoImageView.frame.height - adaptConstant(79) && self.viewIsDark! {
                showNavBar()
            }
            
            if scrollView.contentOffset.y < recipeHeaderView.photoImageView.frame.height - adaptConstant(79) && !self.viewIsDark! {
                showTopView()
            }
            
        } else {
            menuBar.horizontalBarLeftConstraint?.constant = scrollView.contentOffset.x / 3
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView != self.scrollView {
            let index = targetContentOffset.pointee.x / view.frame.width
            let indexPath = IndexPath(item: Int(index), section: 0)
            menuBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition())
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let recipe = recipe else { return UICollectionViewCell() }
        switch indexPath.item {
        case 0:
            let aboutCell = collectionView.dequeueReusableCell(withReuseIdentifier: "aboutCell", for: indexPath) as! AboutCell
            // servings, difficulty, time
            // description
            // rating
            self.aboutCellScrollView = aboutCell.scrollView
            aboutCell.scrollView.delegate = self
            
            if let description = recipe.description {
                aboutCell.descriptionText.text = description
            } else {
                aboutCell.descriptionStackView.isHidden = true
            }
            
            aboutCell.servingsInfoBox.infoLabel.text = "\(recipe.servings) servings"
            aboutCell.timeInfoBox.infoLabel.text = "\(recipe.timeInMinutes) minutes"
            aboutCell.difficultyInfoBox.infoLabel.text = "\(recipe.difficulty)"
            
            return aboutCell
        case 1:
            let ingredientsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ingredientsCell", for: indexPath) as! IngredientsCell
            // ingredients array
            ingredientsCell.ingredients = recipe.ingredients
            self.ingredientsCellTableView = ingredientsCell.tableView
            
            return ingredientsCell
        case 2:
            let directionsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "directionsCell", for: indexPath) as! DirectionsCell
            // directions array
            directionsCell.steps = recipe.steps
            if let videoURL = recipe.videoURL {
                directionsCell.videoURL = videoURL
                directionsCell.thumbnailURL = recipe.thumbnailURL!
                directionsCell.hasVideo = true
            }
            directionsCell.recipeDetailVC = self
            self.directionsCellTableView = directionsCell.tableView
            
            return directionsCell
        default:
            print("No cell found.")
        }
        return UICollectionViewCell()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}
