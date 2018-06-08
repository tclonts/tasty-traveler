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
import CoreLocation
import MapKit
import Social
import FacebookShare

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
            
            if userID == recipe!.creator.uid {
                isMyRecipe = true
                // my recipe
                recipeHeaderView.favoriteButton.isHidden = true
                favoriteButtonNavBar.isHidden = true
                self.bottomView.isHidden = true
            } else {
                isMyRecipe = false
                // someone else's recipe
                if recipe!.hasFavorited {
                    recipeHeaderView.favoriteButton.setImage(#imageLiteral(resourceName: "favoriteButtonSelected"), for: .normal)
                    favoriteButtonNavBar.setTitle("SAVED", for: .normal)
                    favoriteButtonNavBar.setImage(#imageLiteral(resourceName: "favoriteNavSelected"), for: .normal)
                } else {
                    recipeHeaderView.favoriteButton.setImage(#imageLiteral(resourceName: "favoriteButton"), for: .normal)
                    favoriteButtonNavBar.setTitle("SAVE", for: .normal)
                    favoriteButtonNavBar.setImage(#imageLiteral(resourceName: "favoriteNav"), for: .normal)
                }
            
                formatCookButton()
            }
            
            fetchReviewData()

        }
    }
    
    let topView: UIImageView = {
        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "topGradient")
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let navigationBarBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let navigationBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        let separator = UIView()
        separator.backgroundColor = Color.lightGray
        
        view.sv(separator)
        separator.bottom(0).left(0).right(0).height(0.5)
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
        button.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
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
        button.titleLabel?.font = ProximaNova.regular.of(size: 13)
        button.setTitleColor(Color.darkGrayText, for: .normal)
        button.setImage(#imageLiteral(resourceName: "favoriteNav"), for: .normal)
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
        view.backgroundColor = .clear
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
        
        button.layer.cornerRadius = adaptConstant(10)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = CGFloat(16)
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.layer.shadowOpacity = 0.16
        
        return button
    }()
    
    lazy var askButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = Color.primaryOrange
        button.setCustomTitle(string: "Ask a question", font: ProximaNova.semibold.of(size: 16), textColor: .white, for: .normal)
        button.addTarget(self, action: #selector(askButtonTapped), for: .touchUpInside)
        button.contentHorizontalAlignment = .center
        
        button.layer.cornerRadius = adaptConstant(10)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = CGFloat(16)
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.layer.shadowOpacity = 0.16
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
    var didSubmitReview = false
    var previousCreatorID: String?
    
    var ratings: [Int]?
    var averageRating: Double?
    var reviews = [Review]() {
        didSet {
            // we need number of reviews and average rating from reviews
            self.ratings = reviews.flatMap { $0.rating }
            guard let ratings = self.ratings else {
                NotificationCenter.default.post(name: Notification.Name("ReviewsLoaded"), object: nil)
                return
            }
            let sumOfRatings = ratings.reduce(0, +)
            // average = sumOfRatings / ratings.count
            self.averageRating = Double(sumOfRatings) / Double(ratings.count)
            self.recipeHeaderView.starRating.rating = averageRating!
            self.recipeHeaderView.starRating.text = "(\(ratings.count))"
            
            var numbersOfEachStar = [Double]()
            for n in 1...5 {
                numbersOfEachStar.append(Double(ratings.filter { $0 == n }.count))
            }
            let fiveStarRating = Array(numbersOfEachStar.reversed())
            
            let recipeScore = starRating(ns: fiveStarRating)
            FirebaseController.shared.ref.child("recipes").child(recipe!.uid).child("recipeScore").setValue(recipeScore)
            
            NotificationCenter.default.post(name: Notification.Name("ReviewsLoaded"), object: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.isHeroEnabled = true
        self.view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationBar.isHidden = true
        self.navigationBarBackground.isHidden = true
        
        //edgesForExtendedLayout = UIRectEdge.top
        //extendedLayoutIncludesOpaqueBars = true

        recipeHeaderView.heroID = "recipeHeaderView"
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadRecipe), name: Notification.Name("submittedReview"), object: nil)
        
        setUpViews()
        applyHeroModifiers()
        
        viewIsDark = true
                
        if isMyRecipe { reloadRecipe() }
        
        recipeHeaderView.countryLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showMapView))
        self.recipeHeaderView.countryLabel.addGestureRecognizer(tapGesture)
        
        if !isMyRecipe {
            let profileGesture = UITapGestureRecognizer(target: self, action: #selector(showProfileView))
            self.recipeHeaderView.creatorNameLabel.isUserInteractionEnabled = true
            self.recipeHeaderView.creatorNameLabel.addGestureRecognizer(profileGesture)
        }
    }
    
    @objc func showProfileView() {
        guard let uid = recipe?.creator.uid else { return }
        if let previousCreatorID = previousCreatorID, previousCreatorID == uid {
            self.dismiss(animated: true, completion: nil)
        } else {
            
            let profileVC = ProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
            profileVC.isMyProfile = false
            profileVC.userID = uid
            self.present(profileVC, animated: true, completion: nil)
        }
    }
    
    @objc func showMapView() {
        print("SHOW")
        guard let recipe = self.recipe, let coordinate = recipe.coordinate else { return }
        
        let popup = StaticMapView()
        popup.modalPresentationStyle = .overCurrentContext
        popup.coordinate = coordinate
        self.present(popup, animated: false) {
            popup.showMapView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        topView.topConstraint?.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    @objc func reloadRecipe() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        FirebaseController.shared.fetchRecipeWithUID(uid: recipe!.uid) { (recipe) in
            guard let recipe = recipe else { return }
            
            var updatedRecipe = recipe
    
            FirebaseController.shared.ref.child("users").child(userID).child("favorites").child(recipe.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if (snapshot.value as? Double) != nil {
                    updatedRecipe.hasFavorited = true
                } else {
                    updatedRecipe.hasFavorited = false
                }
                
                FirebaseController.shared.ref.child("users").child(userID).child("cookedRecipes").child(recipe.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    if (snapshot.value as? Double) != nil {
                        updatedRecipe.hasCooked = true
                        let timestamp = (snapshot.value as! Double)
                        updatedRecipe.cookedDate = Date(timeIntervalSince1970: timestamp)
                    } else {
                        updatedRecipe.hasCooked = false
                    }
                    
                    self.recipe = updatedRecipe
                    if !self.isFromFavorites {
                        self.homeVC!.searchResultRecipes[self.homeVC!.previousIndexPath!.item] = self.recipe!
                        self.homeVC?.recipeDataHasChanged = true
                    }
                })
            })
        }
    }
    
    @objc func fetchReviewData() {
        
        var incomingReviews = [Review]()
        
        guard let reviewsDictionary = recipe?.reviewsDictionary else {
            self.recipeHeaderView.starRating.rating = 0
            self.recipeHeaderView.starRating.text = "0"
            self.averageRating = 0
            self.ratings = nil
            
            NotificationCenter.default.post(name: Notification.Name("ReviewsLoaded"), object: nil)
            return
        }
        
        let group = DispatchGroup()
        
        reviewsDictionary.forEach({ (key, value) in
            
            group.enter()
            
            FirebaseController.shared.ref.child("reviews").child(value).observeSingleEvent(of: .value) { (snapshot) in
                guard let reviewDictionary = snapshot.value as? [String:Any] else { group.leave(); return }
                
                var review = Review(uid: value, dictionary: reviewDictionary)
                
                FirebaseController.shared.fetchUserWithUID(uid: key, completion: { (user) in
                    guard let user = user else { group.leave(); return }
                    review.user = user
                    
                    incomingReviews.append(review)
                    
                    group.leave()
                })
            }
        })
        
        group.notify(queue: .main) {
            if !incomingReviews.isEmpty {
                incomingReviews.sort(by: { (r1, r2) -> Bool in
                    if r1.upvotes == r2.upvotes {
                        return r1.creationDate.compare(r2.creationDate) == .orderedDescending
                    } else {
                        return r1.upvotes > r2.upvotes
                    }
                })
                self.reviews = incomingReviews
            }
        }
    }
    
    @objc func backButtonTapped() {
        self.hero_dismissViewController()
    }
    
    @objc func shareButtonTapped() {
        self.recipeHeaderView.mealLabel.isHidden = true
        self.recipeHeaderView.favoriteButton.isHidden = true
        UIGraphicsBeginImageContextWithOptions(self.recipeHeaderView.bounds.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            self.recipeHeaderView.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            let vc = UIActivityViewController(activityItems: [image!], applicationActivities: [])
            present(vc, animated: true, completion: nil)
        }
        self.recipeHeaderView.mealLabel.isHidden = false
        self.recipeHeaderView.favoriteButton.isHidden = false
    }
    
    @objc func favoriteButtonNavTapped() {
        favoriteRecipe()
    }
    
    @objc func cookButtonTapped() {
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        if !recipe!.hasCooked {
            recipe?.cookedDate = Date()
            recipe?.hasCooked = true
            let popup = CookedItAlertView()
            popup.modalPresentationStyle = .overCurrentContext
            popup.recipeID = recipe!.uid
            self.present(popup, animated: false) {
                popup.showAlertView()
            }
            
        } else {
            let ac = UIAlertController(title: "Mark this recipe as not cooked?", message: "This will permanently delete your rating/review for this recipe as well.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
                FirebaseController.shared.ref.child("users").child(userID).child("cookedRecipes").child(self.recipe!.uid).removeValue()
                FirebaseController.shared.ref.child("users").child(userID).child("reviewedRecipes").child(self.recipe!.uid).removeValue()
                FirebaseController.shared.ref.child("recipes").child(self.recipe!.uid).child("reviews").child(userID).removeValue()
                
                NotificationCenter.default.post(name: Notification.Name("submittedReview"), object: nil)
                NotificationCenter.default.post(name: Notification.Name("FavoritesChanged"), object: nil)
                
                
                self.recipe?.cookedDate = nil
                self.recipe?.hasCooked = false
                
                if !self.isFromFavorites {
                    self.homeVC!.searchResultRecipes[self.homeVC!.previousIndexPath!.item] = self.recipe!
                    self.homeVC?.recipeDataHasChanged = true
                }

                ac.dismiss(animated: true, completion: nil)
            }))
            ac.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(ac, animated: true, completion: nil)
        }
    }
    
    func formatCookButton() {
        if recipe!.hasCooked {
            guard let cookedDate = recipe?.cookedDate else { return }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            
            cookLabel.text = "Cooked"
            cookLabel.textColor = Color.gray
            self.cookButton.layer.borderWidth = 1
            self.cookButton.layer.borderColor = Color.gray.cgColor
            
            cookedDateLabel.text = dateFormatter.string(from: cookedDate)
            UIView.animate(withDuration: 0.3, animations: {
                self.cookedDateLabel.isHidden = false
                self.cookButton.layer.shadowOpacity = 0
                self.cookButton.layoutIfNeeded()
            })
        } else {
            cookLabel.text = "Cooked it!"
            cookLabel.textColor = Color.primaryOrange
            
            
            UIView.animate(withDuration: 0.3, animations: {
                self.cookedDateLabel.isHidden = true
                self.cookButton.layer.borderWidth = 0
                self.cookButton.layer.shadowOpacity = 0.16
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
                    }
                    
                    NotificationCenter.default.post(name: Notification.Name("FavoritesChanged"), object: nil)
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        print("layed out")
        print(recipeHeaderView.photoImageView.image?.size)
        
        print(recipeHeaderView.photoImageView.frame.size)
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
            self.navigationBar.alpha = 0
            self.navigationBarBackground.alpha = 0
            self.recipeHeaderView.favoriteButton.alpha = 1
            self.favoriteButtonNavBar.alpha = 0
            self.setNeedsStatusBarAppearanceUpdate()
        }) { (complete) in
            self.navigationBar.isHidden = true
            self.navigationBarBackground.isHidden = true
            if !self.isMyRecipe {
                self.favoriteButtonNavBar.isHidden = true
            }
            self.viewIsDark = true
        }
    }
    
    func showNavBar() {
        self.navigationBar.alpha = 0
        self.navigationBar.isHidden = false
        self.navigationBarBackground.alpha = 0
        self.navigationBarBackground.isHidden = false
        
        self.favoriteButtonNavBar.alpha = 0
        if !self.isMyRecipe {
            self.favoriteButtonNavBar.isHidden = false
        }
        viewIsDark = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.navigationBar.alpha = 1
            self.navigationBarBackground.alpha = 1
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
        
        self.view.sv(navigationBarBackground, navigationBar.sv(backButtonNav, favoriteButtonNavBar, shareButtonNav))
        
        navigationBarBackground.Top == self.view.Top
        navigationBarBackground.Left == self.view.Left
        navigationBarBackground.Right == self.view.Right
        navigationBarBackground.Bottom == navigationBar.Bottom
        
        navigationBar.height(44)
        navigationBar.Top == view.safeAreaLayoutGuide.Top
        navigationBar.Left == view.safeAreaLayoutGuide.Left
        navigationBar.Right == view.safeAreaLayoutGuide.Right
        
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
    
//    lazy var topMenuBarConstraintFixed = menuBar.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 0)
//    lazy var topMenuBarConstraint = menuBar.topAnchor.constraint(equalTo: recipeHeaderView.bottomAnchor, constant: adaptConstant(12))
    
    func setUpScrollView() {
        scrollView.delegate = self
        scrollView.left(0).right(0).top(0).bottom(0)
        
        let bottomBarHeight = isMyRecipe ? 0 : adaptConstant(45)
        
        if screenHeight == iPhoneXScreenHeight {
            scrollView.contentInset = UIEdgeInsets(top: -45, left: 0, bottom: 0, right: 0)
        } else {
            scrollView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        }
        
        scrollView.contentInset.bottom = adaptConstant(57)
        
        scrollView.sv(
            containerView.sv(
                recipeHeaderView,
                menuBar,
                collectionView
            )
        )
        
        recipeHeaderView.countryLabel.textColor = Color.primaryOrange
        
        let globeIcon = UIImageView()
        globeIcon.image = #imageLiteral(resourceName: "mapIcon")
        recipeHeaderView.sv(globeIcon)
        globeIcon.Left == recipeHeaderView.countryLabel.Right + 8
        globeIcon.CenterY == recipeHeaderView.countryLabel.CenterY
        globeIcon.isUserInteractionEnabled = true
        globeIcon.height(adaptConstant(15)).width(adaptConstant(15))
        globeIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showMapView)))
        
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
        
        recipeHeaderView.starRating.right(margin)
        recipeHeaderView.starRating.CenterY == recipeHeaderView.creatorNameLabel.CenterY
        
        recipeHeaderView.creatorNameLabel.bottom(adaptConstant(16))
        
        recipeHeaderView.favoriteButton.right(adaptConstant(20))
        recipeHeaderView.favoriteButton.CenterY == recipeHeaderView.photoImageView.Bottom
        recipeHeaderView.favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        
        menuBar.left(0).right(0).height(adaptConstant(40))
        menuBar.Top == recipeHeaderView.Bottom + adaptConstant(12)
        //topMenuBarConstraint.isActive = true
        
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
        bottomView.left(adaptConstant(12)).right(adaptConstant(12)).height(adaptConstant(45))
        
        bottomView.Bottom == view.safeAreaLayoutGuide.Bottom - adaptConstant(12)
        
        bottomView.sv(cookButton, askButton)
        
        let margins = adaptConstant(36)
        
        cookButton.width((self.view.frame.width - margins) / 2)
        cookButton.left(0).top(0).bottom(0)
        
        askButton.width((self.view.frame.width - margins) / 2)
        askButton.right(0).top(0).bottom(0)
    }
    
    var isInAboutCellScrollView = false
    
    var isFromFavorites = false
    
    var aboutCellScrollPosition: CGPoint?
    var ingredientsCellScrollPosition: CGPoint?
    var directionsCellScrollPosition: CGPoint?
}

extension RecipeDetailVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView && aboutCellScrollView != nil {
//            aboutCellScrollView!.isScrollEnabled = (self.scrollView.contentOffset.y >= (self.scrollView.contentSize.height - self.scrollView.frame.size.height))
            if let tableView = ingredientsCellTableView {
                if tableView.contentSize.height > tableView.frame.size.height {
                    ingredientsCellTableView?.isScrollEnabled = (self.scrollView.contentOffset.y >= (self.scrollView.contentSize.height - self.scrollView.frame.size.height))
                }
            }
        }

        if scrollView == self.aboutCellScrollView && aboutCellScrollView != nil {
            // if the scrollview.contentoffset.y > 0 then allow scrolling
            //
//            if scrollView.contentOffset.y > 0 {
//                scrollView.isScrollEnabled = true
//            } else if scrollView.contentOffset.y == 0 {
//                scrollView.isScrollEnabled = scrollView.panGestureRecognizer.translation(in: scrollView.superview).y < 0
//            } else {
//                scrollView.isScrollEnabled = false
//            }
            
            if scrollView.contentOffset.y < 0 { isInAboutCellScrollView = true }
            
            
            if isInAboutCellScrollView {
                scrollView.isScrollEnabled = true
                isInAboutCellScrollView = false
            } else {
                scrollView.isScrollEnabled = scrollView.contentOffset.y > 0
            }

            if aboutCellScrollView!.contentOffset.y > 0 {
                self.aboutCellScrollView!.isScrollEnabled = (aboutCellScrollView!.contentOffset.y > 0)
            }
         
        }
        
        if scrollView == self.scrollView {
//            if scrollView.contentOffset.y >= menuBar.frame.origin.y {
//                topMenuBarConstraint.isActive = false
//                topMenuBarConstraintFixed.isActive = true
//                // self.view.layoutIfNeed()
//            } else {
//                topMenuBarConstraintFixed.isActive = false
//                topMenuBarConstraint.isActive = true
//            }
            
            if viewIsDark == nil { return }
            let photoHeight = self.view.frame.width * 0.75
            if scrollView.contentOffset.y >= photoHeight - adaptConstant(79) && self.viewIsDark!  {
                showNavBar()
            }
            
            if scrollView.contentOffset.y < photoHeight - adaptConstant(79) && !self.viewIsDark!  {
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
            
            let position = CGPoint(x: 0, y: self.menuBar.frame.origin.y)
            if position.y < self.scrollView.contentOffset.y {
                
                if indexPath.item == 0 {
                    self.ingredientsCellScrollPosition = self.scrollView.contentOffset
                    //                guard aboutCellScrollPosition != nil else { return }
                    //                self.scrollView.setContentOffset(aboutCellScrollPosition!, animated: true)
                }
                
                if indexPath.item == 1 {
                    if velocity.x > 0 {
                        print("FROM ABOUT")
                        self.aboutCellScrollPosition = self.scrollView.contentOffset
                        guard ingredientsCellScrollPosition != nil else {
                            let position = CGPoint(x: 0, y: self.menuBar.frame.origin.y)
                            self.scrollView.setContentOffset(position, animated: true)
                            return
                        }
                        self.scrollView.setContentOffset(ingredientsCellScrollPosition!, animated: true)
                    }
                    
                    if velocity.x < 0 {
                        print("FROM DIRECTIONS")
                        self.directionsCellScrollPosition = self.scrollView.contentOffset
                        guard ingredientsCellScrollPosition != nil else { return }
                        self.scrollView.setContentOffset(ingredientsCellScrollPosition!, animated: true)
                    }
                    
                }
                
                if indexPath.item == 2 {
                    self.ingredientsCellScrollPosition = self.scrollView.contentOffset
                    guard directionsCellScrollPosition != nil else { return }
                    self.scrollView.setContentOffset(directionsCellScrollPosition!, animated: true)
                }
            }
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
            aboutCell.delegate = self
            aboutCell.recipeDetailVC = self
            aboutCell.recipeID = recipe.uid
            aboutCell.refreshUserRating()
            
            // FOR TESTING:
            //aboutCell.coordinate = CLLocationCoordinate2D(latitude: 28.588946485659555, longitude: -81.74873004807934)
            
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
        let fromIndex = collectionView.indexPathsForVisibleItems[0].item
        collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: true)
        let position = CGPoint(x: 0, y: self.menuBar.frame.origin.y)
        if position.y < self.scrollView.contentOffset.y {
            adjustContentOffset(index: indexPath.item, from: fromIndex)
        }
    }
    
    func adjustContentOffset(index: Int, from fromIndex: Int) {
        if index == 0 {
            if fromIndex == 1 {
                print("FROM INGREDIENTS")
                self.ingredientsCellScrollPosition = self.scrollView.contentOffset
            } else {
                print("FROM DIRECTIONS")
                self.directionsCellScrollPosition = self.scrollView.contentOffset
            }
        }
        
        if index == 1 {
            if fromIndex == 0 {
                print("FROM ABOUT")
                guard ingredientsCellScrollPosition != nil else {
                    let position = CGPoint(x: 0, y: self.menuBar.frame.origin.y)
                    self.scrollView.setContentOffset(position, animated: true)
                    return
                }
                self.scrollView.setContentOffset(ingredientsCellScrollPosition!, animated: true)
            } else {
                print("FROM DIRECTIONS")
                self.directionsCellScrollPosition = self.scrollView.contentOffset
                guard ingredientsCellScrollPosition != nil else { return }
                self.scrollView.setContentOffset(ingredientsCellScrollPosition!, animated: true)
            }
            
        }
        
        if index == 2 {
            if fromIndex == 0 {
                print("FROM ABOUT")
                guard directionsCellScrollPosition != nil else {
                    let position = CGPoint(x: 0, y: self.menuBar.frame.origin.y)
                    self.scrollView.setContentOffset(position, animated: true)
                    return
                }
                self.scrollView.setContentOffset(directionsCellScrollPosition!, animated: true)
            } else {
                print("FROM INGREDIENTS")
                self.ingredientsCellScrollPosition = self.scrollView.contentOffset
                guard directionsCellScrollPosition != nil else { return }
                self.scrollView.setContentOffset(directionsCellScrollPosition!, animated: true)
            }
        }
    }
}

extension RecipeDetailVC: AboutCellDelegate {
    func presentComposeReviewView() {
        guard let userID = Auth.auth().currentUser?.uid, let recipeID = recipe?.uid else { return }
        
        let composeVC = ComposeReviewVC(style: .plain)
        composeVC.recipeID = recipeID
        composeVC.userID = userID
        composeVC.recipeDetailVC = self
        
        let composeNav = UINavigationController(rootViewController: composeVC)
        present(composeNav, animated: true, completion: nil)
    }
    
    func resizeCollectionView(forHeight height: CGFloat) {
        self.collectionView.heightConstraint?.constant = height
        self.view.layoutIfNeeded()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
        scrollView.setContentOffset(bottomOffset, animated: true)
    }
}

func starRating(ns: [Double]) -> Double {
    let N = ns.reduce(0, +)
    let K = Double(ns.count)
    let s: [Double] = [5, 4, 3, 2, 1]
    let s2 = s.map { pow($0, 2)}
    let z = 1.65
    
    func f(_ s: [Double], _ ns: [Double]) -> Double {
        let N = ns.reduce(0,+)
        let K = Double(ns.count)
        let zipped = zip(s, ns)
        var array = [Double]()
        zipped.forEach { (sk, nk) in
            array.append(sk * (nk + 1.0))
        }
        return (array.reduce(0,+) / (N+K))
    }
    let fsns = f(s, ns)
    let val = (f(s2, ns) - pow(fsns, 2)) / (N + K + 1.0)
    return fsns - (z * val.squareRoot())
}
