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
import FirebaseAuth
import SVProgressHUD

class RecipeDetailVC: UIViewController {
    
    var recipe: Recipe? {
        didSet {
            
            guard let userID = Auth.auth().currentUser?.uid else { print("USER IS NOT LOGGED IN"); return }
                
            if let countryCode = recipe?.countryCode, let locality = recipe?.locality {
                recipeHeaderView.countryFlag.image = UIImage(named: countryCode)
                recipeHeaderView.countryLabel.text = "\(locality), \(countryCode)"
            } else {
                recipeHeaderView.countryFlag.image = nil
                recipeHeaderView.countryLabel.text = "Location Unavailable"
            }
            
            if let meal = recipe?.meal {
                self.recipeHeaderView.mealLabel.text = "  \(meal)  "
            }
            
            recipeHeaderView.recipeNameLabel.text = recipe?.name
            recipeHeaderView.creatorNameLabel.text = "by \(recipe!.creator.username)"
            
            if let overallRating = recipe?.overallRating {
                recipeHeaderView.starsImageView.image = starsImageForRating(overallRating.round(nearest: 0.5))
            } else {
                recipeHeaderView.starsImageView.isHidden = true
                recipeHeaderView.numberOfRatingsLabel.text = "No Ratings"
            }
            
            if userID == recipe!.creator.uid {
                isMyRecipe = true
                // my recipe
                recipeHeaderView.favoriteButton.isHidden = true
                favoriteButtonNavBar.isHidden = true
                self.bottomView.isHidden = true
            } else {
                isMyRecipe = false
                // someone else's recipe
                recipe!.hasFavorited ? recipeHeaderView.favoriteButton.setImage(#imageLiteral(resourceName: "favoriteButtonSelected"), for: .normal) : recipeHeaderView.favoriteButton.setImage(#imageLiteral(resourceName: "favoriteButton"), for: .normal)
            }
            
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
        
        let attributedText = NSAttributedString(string: "SHARE", attributes: [NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(13))!,
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
        //button.addTarget(self, action: #selector(favoriteButtonNavTapped), for: .touchUpInside)
        button.isUserInteractionEnabled = false
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        button.alpha = 0
        return button
    }()
    
    lazy var favoriteButtonNavBar: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(favoriteButtonNavTapped), for: .touchUpInside)
        
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        button.alpha = 0
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
        menuBar.delegate = self
        menuBar.setUpHorizontalBar(onTop: false)
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
    
    let cookLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.semibold.of(size: 16)
        label.text = "Cooked it!"
        label.textColor = Color.primaryOrange
        label.textAlignment = .center
        return label
    }()
    
    let cookedDateLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.semibold.of(size: 12)
        label.textColor = Color.gray
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    lazy var cookButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(cookButtonTapped), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [cookLabel, cookedDateLabel])
        stackView.axis = .vertical
//        stackView.alignment = .center
        
        button.sv(stackView)
        stackView.left(0).right(0)
        stackView.centerVertically()
        stackView.isUserInteractionEnabled = false
        
        return button
    }()
    
    lazy var askButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = Color.primaryOrange
        button.setCustomTitle(string: "Message", font: ProximaNova.semibold.of(size: 16), textColor: .white, for: .normal)
        button.addTarget(self, action: #selector(askButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let margin = adaptConstant(18)
    var aboutCellScrollView: UIScrollView?
    var ingredientsCellTableView: UITableView?
    var directionsCellTableView: UITableView?
    weak var homeVC: HomeVC?
    
    var viewIsDark: Bool?
    var isMyRecipe = false
    var isFromChatLogVC = false
    
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
        
        let attributedText = NSAttributedString(string: "SAVE", attributes: [NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(13))!, NSAttributedStringKey.foregroundColor: Color.darkGrayText])
        favoriteButtonNavBar.setAttributedTitle(attributedText, for: .normal)
        favoriteButtonNavBar.setImage(#imageLiteral(resourceName: "favoriteNav"), for: .normal)
        
        viewIsDark = true
        
        formatCookButton()
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
    
    @objc func favoriteButtonNavTapped() {
        favoriteRecipe()
    }
    
    @objc func cookButtonTapped() {
        recipe?.cookedDate = recipe?.cookedDate == nil ? Date() : nil
        recipe?.hasCooked = !recipe!.hasCooked
        formatCookButton()
        
        if recipe!.hasCooked {
            let popup = CookedItAlertView()
            popup.modalPresentationStyle = .overCurrentContext
            
            self.present(popup, animated: false) {
                popup.showAlertView()
            }
        }
    }
    
    func formatCookButton() {
        if recipe!.hasCooked {
            guard let cookedDate = recipe?.cookedDate else { return }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            
            cookLabel.text = "Cooked"
            cookLabel.textColor = Color.gray
            cookedDateLabel.text = dateFormatter.string(from: cookedDate)
            UIView.animate(withDuration: 0.3, animations: {
                self.cookedDateLabel.isHidden = false
                
                self.cookButton.layoutIfNeeded()
            })
        } else {
            cookLabel.text = "Cooked it!"
            cookLabel.textColor = Color.primaryOrange
            UIView.animate(withDuration: 0.3, animations: {
                self.cookedDateLabel.isHidden = true
                
                self.cookButton.layoutIfNeeded()
            })
        }
    }
    
    @objc func askButtonTapped() {
        print("ask button tapped")
        
        if isFromChatLogVC {
            dismiss(animated: true, completion: nil)
        } else {
            
            let chatLogVC = ChatLogVC(collectionViewLayout: UICollectionViewFlowLayout())
            let chat = Chat(recipe: self.recipe!, withUser: self.recipe!.creator)
            chatLogVC.chat = chat
            chatLogVC.isFromRecipeDetailView = true
            let chatLogNav = UINavigationController(rootViewController: chatLogVC)
            chatLogNav.navigationBar.isTranslucent = false
            chatLogNav.modalPresentationStyle = .overCurrentContext
            
            self.present(chatLogNav, animated: true, completion: nil)
        }
        //navigationController?.pushViewController(chatLogVC, animated: true)
    }
    
    func setUpFavoriteButtons() {
        if recipe!.hasFavorited {
            SVProgressHUD.showSuccess(withStatus: "Saved")
            SVProgressHUD.dismiss(withDelay: 1)
            recipeHeaderView.favoriteButton.setImage(#imageLiteral(resourceName: "favoriteButtonSelected"), for: .normal)
            
        } else {
            SVProgressHUD.showError(withStatus: "Removed")
            SVProgressHUD.dismiss(withDelay: 1)
            recipeHeaderView.favoriteButton.setImage(#imageLiteral(resourceName: "favoriteButton"), for: .normal)
        }
    }
    
    func favoriteRecipe() {
        guard let recipeID = recipe?.uid else { return }
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        if self.recipe!.hasFavorited {
            // remove
            FirebaseController.shared.ref.child("recipes").child(recipeID).child("favoritedBy").child(userID).removeValue()
            FirebaseController.shared.ref.child("users").child(userID).child("favorites").child(recipeID).removeValue()
            
            SVProgressHUD.showError(withStatus: "Removed")
            SVProgressHUD.dismiss(withDelay: 1)
            
            self.recipe?.hasFavorited = false
            
            if !isFromFavorites {
                self.homeVC!.searchResultRecipes[self.homeVC!.previousIndexPath!.item] = self.recipe!
                self.homeVC?.recipeDataHasChanged = true
            } else {
                NotificationCenter.default.post(name: Notification.Name("RecipeUploaded"), object: nil)
            }
            
            NotificationCenter.default.post(name: Notification.Name("FavoritesChanged"), object: nil)
            
        } else {
            // add
            FirebaseController.shared.ref.child("recipes").child(recipeID).child("favoritedBy").child(userID).setValue(true) { (error, _) in
                if let error = error {
                    print("Failed to favorite recipe:", error)
                    return
                }
                
                let timestamp = Date().timeIntervalSince1970
                
                FirebaseController.shared.ref.child("users").child(userID).child("favorites").child(recipeID).setValue(timestamp) { (error, _) in
                    if let error = error {
                        print("Failted to favorite recipe:", error)
                        return
                    }
                    
                    print("Successfully favorited recipe.")
                    
                    SVProgressHUD.showSuccess(withStatus: "Saved")
                    SVProgressHUD.dismiss(withDelay: 1)
                    
                    self.recipe?.hasFavorited = true
                    
                    if !self.isFromFavorites {
                        self.homeVC!.searchResultRecipes[self.homeVC!.previousIndexPath!.item] = self.recipe!
                        self.homeVC?.recipeDataHasChanged = true
                    } else {
                        NotificationCenter.default.post(name: Notification.Name("RecipeUploaded"), object: nil)
                    }
                    
                    NotificationCenter.default.post(name: Notification.Name("FavoritesChanged"), object: nil)
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        print("layed out")
    }
    
    @objc func favoriteButtonTapped() {
        favoriteRecipe()
    }
    
    func showTopView() {
        self.topView.alpha = 0
        self.topView.isHidden = false
        viewIsDark = true
        
        UIView.animate(withDuration: 0.3, animations: {
            self.topView.alpha = 1
            self.navigationController?.navigationBar.alpha = 0
            self.recipeHeaderView.favoriteButton.alpha = 1
            self.favoriteButtonNavBar.alpha = 0
            self.setNeedsStatusBarAppearanceUpdate()
        }) { (complete) in
            self.navigationController?.navigationBar.isHidden = true
            if !self.isMyRecipe {
                self.favoriteButtonNavBar.isHidden = true
            }
            self.viewIsDark = true
        }
    }
    
    func showNavBar() {
        self.navigationController?.navigationBar.alpha = 0
        self.navigationController?.navigationBar.isHidden = false
        
        self.favoriteButtonNavBar.alpha = 0
        if !self.isMyRecipe {
            self.favoriteButtonNavBar.isHidden = false
        }
        viewIsDark = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.navigationController?.navigationBar.alpha = 1
            self.topView.alpha = 0
            self.favoriteButtonNavBar.alpha = 1
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
        
        self.navigationController?.navigationBar.sv(backButtonNav, favoriteButtonNavBar, shareButtonNav)
        
        shareButtonNav.right(adaptConstant(20))
        shareButtonNav.centerVertically()
        
        favoriteButtonNavBar.Right == shareButtonNav.Left - 30
        favoriteButtonNavBar.width(adaptConstant(69))
        favoriteButtonNavBar.centerVertically()
        
        backButtonNav.left(adaptConstant(20))
        backButtonNav.centerVertically()
        
        setUpScrollView()
        setUpTopView()
        setUpBottomView()
    }
    
    func setUpTopView() {
        topView.sv(backButton, shareButton)
        
        if screenHeight == iPhoneXScreenHeight {
            topView.top(-adaptConstant(104)).left(0).right(0).height(adaptConstant(104))
        } else {
            topView.top(-adaptConstant(79)).left(0).right(0).height(adaptConstant(79))
        }
        
        backButton.left(20)
        backButton.centerVertically()
        
        shareButton.right(20)
        shareButton.centerVertically()
    }
    
    func setUpScrollView() {
        scrollView.delegate = self
        scrollView.top(0).left(0).right(0)
        
        if isMyRecipe {
            scrollView.bottom(0)
        } else {
            scrollView.Bottom == bottomView.Top
        }
        
        let bottomBarHeight = isMyRecipe ? 0 : adaptConstant(45)
        
        if screenHeight == iPhoneXScreenHeight {
            scrollView.contentInset = UIEdgeInsets(top: -45, left: 0, bottom: 0, right: 0)
        } else {
            scrollView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        }
        
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
        recipeHeaderView.placeholderImageView.CenterY == recipeHeaderView.photoImageView.CenterY
        recipeHeaderView.placeholderImageView.CenterX == recipeHeaderView.photoImageView.CenterX
        
        recipeHeaderView.mealLabel.left(0)
        recipeHeaderView.mealLabel.Bottom == recipeHeaderView.photoImageView.Bottom - adaptConstant(27)
        recipeHeaderView.mealLabel.height(adaptConstant(20))
        
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
        recipeHeaderView.favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        
        menuBar.left(0).right(0).height(adaptConstant(40))
        menuBar.Top == recipeHeaderView.Bottom + adaptConstant(12)
        
        collectionView.Top == menuBar.Bottom
        collectionView.left(0).right(0).bottom(0)
        // view - recipeheaderview height - navbar height - menu bar height - bottomview height
        if screenHeight == iPhoneXScreenHeight {
            let collectionViewHeight: CGFloat = self.view.frame.height - menuBar.frame.height - recipeHeaderView.frame.height - 64 - menuBar.frame.height - bottomBarHeight - adaptConstant(45) - 20
            collectionView.height(collectionViewHeight)
        } else {
            let collectionViewHeight: CGFloat = self.view.frame.height - menuBar.frame.height - recipeHeaderView.frame.height - 64 - menuBar.frame.height - bottomBarHeight - adaptConstant(45)
            collectionView.height(collectionViewHeight)
        }
    }
    
    func setUpBottomView() {
        bottomView.left(0).right(0).height(adaptConstant(45))
        
        bottomView.Bottom == view.safeAreaLayoutGuide.Bottom
        
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
    
    var isFromFavorites = false
}

extension RecipeDetailVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
            if scrollView.contentOffset.y >= recipeHeaderView.photoImageView.frame.height - adaptConstant(79) && self.viewIsDark! && scrollView.isDragging {
                showNavBar()
            }
            
            if scrollView.contentOffset.y < recipeHeaderView.photoImageView.frame.height - adaptConstant(79) && !self.viewIsDark! && scrollView.isDragging {
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

extension RecipeDetailVC: MenuBarDelegate {
    func scrollToMenuIndex(_ menuIndex: Int) {
        let indexPath = IndexPath(item: menuIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: true)
    }
}
