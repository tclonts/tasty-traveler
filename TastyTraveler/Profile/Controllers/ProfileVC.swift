//
//  ProfileVC.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/14/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Firebase
import GSKStretchyHeaderView
import Stevia
import RSKImageCropper
import SVProgressHUD

private let favoritesSection = "favoritesSectionCell"
private let cookedSection = "cookedSectionCell"
private let uploadedSection = "uploadedSectionCell"
private let sectionHeaderID = "sectionHeader"

class ProfileHeaderView: GSKStretchyHeaderView {
    weak var delegate: ProfileHeaderViewDelegate?
        
    lazy var settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "settings"), for: .normal)
        button.addTarget(self, action: #selector(didTapSettingsButton), for: .touchUpInside)
        return button
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "closeButton"), for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    lazy var notificationsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "notifications"), for: .normal)
        button.addTarget(self, action: #selector(didTapNotificationsButton), for: .touchUpInside)
        return button
    }()
    
    lazy var pointsButton: UIButton = {
        let button = UIButton(type: .system)
        let title = NSAttributedString(string: "\(0)", attributes: [
            NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
            NSAttributedStringKey.foregroundColor: Color.primaryOrange])
        button.setAttributedTitle(title, for: .normal)
        button.addTarget(self, action: #selector(didTapPointsButton), for: .touchUpInside)
        return button
    }()
    
    let profilePhotoImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.image = #imageLiteral(resourceName: "avatar")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 85 / 2
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = Color.primaryOrange.cgColor
        return imageView
    }()
    
    
    lazy var profilePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "profilePhotoButton"), for: .normal)
        button.addTarget(self, action: #selector(didTapProfilPhotoButton), for: .touchUpInside)
        return button
    }()
    
    let followerLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.semibold.of(size: 12)
        label.textColor = Color.blackText
        label.text = "Followers"
        return label
    }()
    
    let pointsLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.semibold.of(size: 12)
        label.textColor = Color.blackText
        label.text = "Points"
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.bold.of(size: 20)
        label.textColor = Color.blackText
        label.text = "Username"
        return label
    }()
    
    lazy var bronzeBadge: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "notifications"), for: .normal)
        button.addTarget(self, action: #selector(didTapPointsButton), for: .touchUpInside)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    lazy var silverBadge: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "notifications"), for: .normal)
        button.addTarget(self, action: #selector(didTapPointsButton), for: .touchUpInside)
        button.isUserInteractionEnabled = false

        return button
    }()
    
    lazy var goldBadge: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "notifications"), for: .normal)
        button.addTarget(self, action: #selector(didTapPointsButton), for: .touchUpInside)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    let countryFlagImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.height(15).width(22)
        return imageView
    }()
    
    let countryLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.semibold.of(size: 12)
        label.textColor = Color.darkGrayText
        return label
    }()
    
    lazy var bioLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.semibold.of(size: 14)
        label.textColor = Color.primaryOrange
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = "Edit Bio"
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToAccountInfo)))
        return label
    }()
    
    let separatorLine: UIView = {
        let view = UIView()
        view.height(0.5)
        view.backgroundColor = Color.lightGray
        return view
    }()
    
    let unreadIndicator = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setUpViews()
    }
    
    @objc func goToAccountInfo() {
        delegate?.goToAccountInfo()
    }
    
    @objc func backButtonTapped() {
        delegate?.didTapBackButton()
    }
    
    override func didChangeStretchFactor(_ stretchFactor: CGFloat) {
        super.didChangeStretchFactor(stretchFactor)
        
        let minA: CGFloat = 40
        let maxA: CGFloat = 85
        let size = CGFloatTranslateRange(min(1,stretchFactor), 0, 1, minA, maxA)
        
        let alphaMin: CGFloat = 0
        let alphaMax: CGFloat = 1
        let alphaAmount = CGFloatTranslateRange(min(1, stretchFactor), 0, 1, alphaMin, alphaMax)
        
        self.profilePhotoImageView.layer.borderColor = Color.primaryOrange.withAlphaComponent(alphaAmount).cgColor
        self.profilePhotoButton.alpha = alphaAmount
        self.usernameLabel.alpha = alphaAmount
        self.countryFlagImageView.alpha = alphaAmount
        self.countryLabel.alpha = alphaAmount
        self.bioLabel.alpha = alphaAmount
        
        self.profilePhotoImageView.widthConstraint?.constant = size
        self.profilePhotoImageView.layer.cornerRadius = size / 2
        
        let minTop: CGFloat = 1
        let maxTop: CGFloat = 12
        let topAmount = CGFloatTranslateRange(min(1,stretchFactor), 0, 1, minTop, maxTop)
        
        self.profileTopConstraint?.constant = topAmount
        
        print(stretchFactor)
        
        
        self.layoutIfNeeded()
    }
    
    var profileTopConstraint: NSLayoutConstraint?
    var profileCenterConstraint: NSLayoutConstraint?
    
    func setUpViews() {
        self.contentView.backgroundColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [countryFlagImageView, countryLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        
        let stackView2 = UIStackView(arrangedSubviews: [bronzeBadge, silverBadge, goldBadge])
        stackView2.axis = .horizontal
        stackView2.spacing = 8
        
        self.contentView.sv(backButton, settingsButton, notificationsButton, profilePhotoImageView, profilePhotoButton, pointsLabel, pointsButton, usernameLabel, stackView, stackView2, bioLabel, separatorLine, unreadIndicator)
        
        backButton.left(20)
        backButton.Top == safeAreaLayoutGuide.Top + 12
        
        settingsButton.left(20)
        settingsButton.Top == safeAreaLayoutGuide.Top + 12
        notificationsButton.right(20)
        notificationsButton.Top == safeAreaLayoutGuide.Top + 12
        
        profilePhotoImageView.width(85)
        profilePhotoImageView.heightEqualsWidth()
        profilePhotoImageView.centerHorizontally()
        
        profileTopConstraint = profilePhotoImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12)
        profileCenterConstraint = profilePhotoImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0)
        profileCenterConstraint?.isActive = true
        profileTopConstraint?.isActive = true
        
        //profilePhotoImageView.Top == safeAreaLayoutGuide.Top + 12
        
        profilePhotoButton.CenterY == profilePhotoImageView.Bottom
        profilePhotoButton.centerHorizontally()
                
        pointsLabel.CenterX == bioLabel.CenterX - contentView.frame.width/4
        pointsLabel.centerVertically()
        
//        pointsLabel.CenterX == usernameLabel.CenterX
//        pointsLabel.Right == usernameLabel.CenterX + contentView.frame.width/3.2
//        pointsLabel.centerVertically()
        
        pointsButton.Top == pointsLabel.Bottom
        pointsButton.CenterX == pointsLabel.CenterX
        
        stackView2.Top == pointsButton.Bottom
        stackView2.CenterX == pointsButton.CenterX
//        stackView2.centerVertically()
        
        usernameLabel.Top == profilePhotoButton.Bottom + 8
        usernameLabel.centerHorizontally()
        
        stackView.Top == usernameLabel.Bottom + 8
        stackView.centerHorizontally()
        
        bioLabel.Top == stackView.Bottom + 12
        bioLabel.left(adaptConstant(40)).right(adaptConstant(40))
        
        separatorLine.left(0).bottom(0).right(0)
        
        unreadIndicator.layer.cornerRadius = 3
        unreadIndicator.clipsToBounds = true
        unreadIndicator.backgroundColor = .red
        unreadIndicator.layer.masksToBounds = true
        unreadIndicator.Top == notificationsButton.Top - 3
        unreadIndicator.Right == notificationsButton.Right + 3
        unreadIndicator.height(6).width(6)
        unreadIndicator.isHidden = true
    }
    
    @objc func didTapSettingsButton() {
        self.delegate?.didTapSettingsButton()
    }
    
    @objc func didTapNotificationsButton() {
        self.delegate?.didTapNotificationsButton()
    }
    
    @objc func didTapProfilPhotoButton() {
        self.delegate?.didTapProfilePhotoButton()
    }
    
    @objc func didTapPointsButton() {
        self.delegate?.didTapPointsButton()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol ProfileHeaderViewDelegate: class {
    func didTapSettingsButton()
    func didTapNotificationsButton()
    func didTapProfilePhotoButton()
    func didTapBackButton()
    func goToAccountInfo()
    func didTapPointsButton()
}

class ProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var headerView: ProfileHeaderView!
    var recipes = [Recipe]()
    var imagePicker: UIImagePickerController?
    
    var isMyProfile = true
    var userID: String?
    var user: TTUser? {
        didSet {
            guard headerView != nil else { return }
            if let username = user?.username {
                headerView.usernameLabel.text = username
            }

            if let bio = user?.bio, bio != "" {
                self.headerView.bioLabel.text = bio
                self.headerView.bioLabel.textColor = Color.darkText
                self.headerView.bioLabel.isUserInteractionEnabled = false
            }
            
            if let urlString = user!.avatarURL {
                self.headerView.profilePhotoImageView.loadImage(urlString: urlString, placeholder: #imageLiteral(resourceName: "avatar"))
            }
            
            if let userPoints = user?.points {
                self.headerView.pointsButton.setTitle("\(userPoints)", for: .normal)
                let title = NSAttributedString(string: "\(userPoints)", attributes: [
                    NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
                    NSAttributedStringKey.foregroundColor: Color.primaryOrange])
                headerView.pointsButton.setAttributedTitle(title, for: .normal)
            }
            
            if user?.badgeStatus == 0 || user?.badgeStatus == nil {
                self.headerView.bronzeBadge.isHidden = true
                self.headerView.silverBadge.isHidden = true
                self.headerView.goldBadge.isHidden = true
            } else if user?.badgeStatus == 1 {
                self.headerView.bronzeBadge.isHidden = true
                self.headerView.silverBadge.isHidden = true
                self.headerView.goldBadge.isHidden = false
            } else if user?.badgeStatus == 2 {
                self.headerView.bronzeBadge.isHidden = true
                self.headerView.silverBadge.isHidden = false
                self.headerView.goldBadge.isHidden = false
            }else if user?.badgeStatus == 3 {
                self.headerView.bronzeBadge.isHidden = false
                self.headerView.silverBadge.isHidden = false
                self.headerView.goldBadge.isHidden = false
            }
            }
        }
    
    
    lazy var emptyDataView: UIStackView = {
        let label = UILabel()
        label.font = UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(20))
        label.text = "You haven't uploaded any recipes."
        label.textColor = Color.gray
        
        let button = UIButton(type: .system)
        let title = NSAttributedString(string: "Create a recipe", attributes: [
            NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
            NSAttributedStringKey.foregroundColor: Color.primaryOrange])
        button.setAttributedTitle(title, for: .normal)
        button.addTarget(self, action: #selector(presentCreateRecipeVC), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [label, button])
        stackView.axis = .vertical
        stackView.spacing = adaptConstant(20)
        stackView.isHidden = true
        return stackView
    }()
    
    let userHasNoRecipesLabel: UILabel = {
        let label = UILabel()
        label.text = "User has not uploaded any recipes."
        label.font = ProximaNova.semibold.of(size: 20)
        label.textColor = Color.gray
        label.isHidden = true
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    @objc func presentCreateRecipeVC() {
        let createRecipeVC = CreateRecipeVC()
        self.present(createRecipeVC, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    @objc func fetchUserInfo() {
        if isMyProfile {
            userID = Auth.auth().currentUser?.uid
        }
        if let uid = userID {
            FirebaseController.shared.fetchUserWithUID(uid: uid, completion: { (user) in
                self.user = user
                
                
                self.fetchRecipes()
            })
        }
    }
    
    @objc func refreshRecipes() {
        self.recipes.removeAll()
        fetchRecipes()
    }
    
    func fetchRecipes() {
        guard let userID = userID else { return }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var incomingRecipes = [Recipe]()
        
        FirebaseController.shared.ref.child("users").child(userID).child("uploadedRecipes").observeSingleEvent(of: .value) { (snapshot) in
            guard let uploadedRecipesDictionary = snapshot.value as? [String:Double] else {
                self.collectionView!.reloadData()
                if self.isMyProfile {
                    self.emptyDataView.isHidden = self.recipes.count != 0
                } else {
                    self.userHasNoRecipesLabel.isHidden = false
                }
                self.headerView.countryLabel.isHidden = true
                self.headerView.countryFlagImageView.isHidden = true
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return
            }
            
            let group = DispatchGroup()
            
            uploadedRecipesDictionary.forEach({ (key, value) in
                group.enter()
                
                FirebaseController.shared.ref.child("recipes").child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let recipeDictionary = snapshot.value as? [String:Any] else { group.leave(); return }
                    
                    var recipe = Recipe(uid: key, creator: self.user!, dictionary: recipeDictionary)
                    
                    guard let currentUserID = Auth.auth().currentUser?.uid else { group.leave(); return }
                    
                    FirebaseController.shared.ref.child("users").child(currentUserID).child("favorites").child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                        if (snapshot.value as? Double) != nil {
                            recipe.hasFavorited = true
                        } else {
                            recipe.hasFavorited = false
                        }
                        
                        incomingRecipes.append(recipe)
                        group.leave()
                    })
                })
            })
            
            group.notify(queue: .main) {
                self.recipes = incomingRecipes
                self.recipes.sort(by: { (r1, r2) -> Bool in
                    return r1.creationDate.compare(r2.creationDate) == .orderedAscending
                })
                
                self.collectionView!.reloadData()
                if self.isMyProfile {
                    self.emptyDataView.isHidden = self.recipes.count != 0
                } else {
                    self.userHasNoRecipesLabel.isHidden = self.recipes.count != 0
                }

                if let recipeForLocation = self.recipes.last, let countryCode = recipeForLocation.countryCode, let locality = recipeForLocation.locality {
                    self.headerView.countryLabel.text = "\(locality), \(countryCode)"
                    self.headerView.countryFlagImageView.image = UIImage(named: countryCode)
                } else {
                    self.headerView.countryLabel.isHidden = true
                    self.headerView.countryFlagImageView.isHidden = true
                }
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if headerView == nil {
            let heightAdded: CGFloat = screenHeight == iPhoneXScreenHeight ? 20 : 0
            let headerSize = CGSize(width: self.view.frame.size.width, height: (245 + heightAdded))
            headerView = ProfileHeaderView(frame: CGRect(x: 0, y: 0, width: headerSize.width, height: headerSize.height))
            headerView.minimumContentHeight = view.safeAreaInsets.top + 44
            headerView.maximumContentHeight = 245 + heightAdded
            headerView.contentExpands = false
            headerView.delegate = self
            collectionView?.addSubview(self.headerView)

            if let username = user?.username {
                headerView.usernameLabel.text = username
            }
            
//            if let userPoints = user?.points {
//                headerView.pointsButton.setTitle("\(userPoints)", for: .normal)
//                let title = NSAttributedString(string: "\(userPoints)", attributes: [
//                    NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
//                    NSAttributedStringKey.foregroundColor: Color.primaryOrange])
//                headerView.pointsButton.setAttributedTitle(title, for: .normal)
//            }
            
            
            if user?.badgeStatus == 0 || user?.badgeStatus == nil {
                self.headerView.bronzeBadge.isHidden = true
                self.headerView.silverBadge.isHidden = true
                self.headerView.goldBadge.isHidden = true
            } else if user?.badgeStatus == 1 {
                self.headerView.bronzeBadge.isHidden = false
                self.headerView.silverBadge.isHidden = true
                self.headerView.goldBadge.isHidden = true
            } else if user?.badgeStatus == 2 {
                self.headerView.bronzeBadge.isHidden = false
                self.headerView.silverBadge.isHidden = false
                self.headerView.goldBadge.isHidden = true
            }else if user?.badgeStatus == 3 {
                self.headerView.bronzeBadge.isHidden = false
                self.headerView.silverBadge.isHidden = false
                self.headerView.goldBadge.isHidden = false
            }

            
            if let bio = user?.bio, bio != "" {
                headerView.bioLabel.text = bio
                headerView.bioLabel.textColor = Color.darkText
                headerView.bioLabel.isUserInteractionEnabled = false
            }
            
            if let urlString = user?.avatarURL {
                headerView.profilePhotoImageView.loadImage(urlString: urlString, placeholder: #imageLiteral(resourceName: "avatar"))
            }
            
            if FirebaseController.shared.unreadNotificationsCount > 0 {
                self.headerView.unreadIndicator.isHidden = false
            } else {
                self.headerView.unreadIndicator.isHidden = true
            }
            
            if !isMyProfile {
                headerView.profilePhotoButton.isHidden = true
                headerView.settingsButton.isHidden = true
                headerView.notificationsButton.isHidden = true
                headerView.unreadIndicator.isHidden = true
                
                if let bio = user?.bio, bio != "" {
                    headerView.bioLabel.text = bio
                    headerView.bioLabel.textColor = Color.darkText
                    headerView.bioLabel.isUserInteractionEnabled = false
                } else {
                    headerView.bioLabel.text = "No bio"
                    headerView.bioLabel.textColor = Color.gray
                    headerView.bioLabel.isUserInteractionEnabled = false
                }
                
                headerView.backButton.isHidden = false
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewLoadSetup()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @objc func toggleIndicator() {
        if FirebaseController.shared.unreadNotificationsCount > 0 {
            self.headerView.unreadIndicator.isHidden = false
        } else {
            self.headerView.unreadIndicator.isHidden = true
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipeCell", for: indexPath) as! FavoriteCell
        cell.favoriteButton.isHidden = true
        cell.recipe = recipes[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width / 2) - adaptConstant(10) - adaptConstant(5)
        return CGSize(width: width, height: width * 0.85)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return adaptConstant(10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return adaptConstant(10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: adaptConstant(10), left: adaptConstant(10), bottom: adaptConstant(10), right: adaptConstant(10))
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! FavoriteCell
        
        guard let recipe = cell.recipe else { return }
        
        if isMyProfile {
            let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            ac.addAction(UIAlertAction(title: "View", style: .default, handler: { (_) in
                
                let recipeDetailVC = RecipeDetailVC()
                recipeDetailVC.recipe = recipe
                recipeDetailVC.recipeHeaderView.photoImageView.loadImage(urlString: recipe.photoURL, placeholder: nil)
                
                let recipeNavigationController = UINavigationController(rootViewController: recipeDetailVC)
                recipeNavigationController.navigationBar.isHidden = true
                recipeDetailVC.isMyRecipe = true
                recipeDetailVC.isFromFavorites = true
                
                self.present(recipeNavigationController, animated: true, completion: nil)
            }))
            
            ac.addAction(UIAlertAction(title: "Edit", style: .default, handler: { (_) in
                let createRecipeVC = CreateRecipeVC()
                createRecipeVC.isEditingRecipe = true
                createRecipeVC.recipe = recipe
                self.present(createRecipeVC, animated: true, completion: nil)
            }))
            
            ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
                
                FirebaseController.shared.ref.child("recipes").child(recipe.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let recipeDictionary = snapshot.value as? [String:Any] else { return }
                    
                    if let favoritedByDictionary = recipeDictionary["favoritedBy"] as? [String:Any] {
                        let favoritedByIDs = Array(favoritedByDictionary.keys)
                        
                        favoritedByIDs.forEach { FirebaseController.shared.ref.child("users").child($0).child("favorites").child(recipe.uid).removeValue() }
                    }
                    
                    FirebaseController.shared.ref.child("users").child(recipe.creator.uid).child("uploadedRecipes").child(recipe.uid).removeValue()
                    FirebaseController.shared.ref.child("recipes").child(recipe.uid).removeValue()
                    if let country = recipe.country { FirebaseController.shared.ref.child("locations").child(country).child("recipes").child(recipe.uid).removeValue() }
                    
                    FirebaseController.shared.ref.child("messages").observeSingleEvent(of: .value, with: { (snapshot) in
                        guard let messagesDictionary = snapshot.value as? [String:Any] else { return }
                        
                        messagesDictionary.forEach({ (key, value) in
                            if let messageRecipeID = (value as! [String:Any])["recipeID"] as? String {
                                if messageRecipeID == recipe.uid { FirebaseController.shared.ref.child("messages").child(key).removeValue() }
                            }
                        })
                    })
                    
                    recipe.reviewsDictionary?.forEach({ (userID, reviewID) in
                        FirebaseController.shared.ref.child("reviews").child(reviewID).removeValue()
                        FirebaseController.shared.ref.child(userID).child("cookedRecipes").child(recipe.uid).removeValue()
                        FirebaseController.shared.ref.child(userID).child("reviewedRecipes").child(recipe.uid).removeValue()
                    })
                })
                self.recipes.remove(at: indexPath.item)
                self.collectionView!.deleteItems(at: [indexPath])
                if self.isMyProfile {
                    self.emptyDataView.isHidden = self.recipes.count != 0
                } else {
                    self.userHasNoRecipesLabel.isHidden = self.recipes.count != 0
                }

                ac.dismiss(animated: true, completion: nil)
            }))
            
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(ac, animated: true, completion: nil)
        } else {
            let recipeDetailVC = RecipeDetailVC()
            recipeDetailVC.recipe = recipe
            recipeDetailVC.recipeHeaderView.photoImageView.loadImage(urlString: recipe.photoURL, placeholder: nil)
            recipeDetailVC.previousCreatorID = self.userID!
            
            let recipeNavigationController = UINavigationController(rootViewController: recipeDetailVC)
            recipeNavigationController.navigationBar.isHidden = true
            recipeDetailVC.isFromFavorites = true
            
            self.present(recipeNavigationController, animated: true, completion: nil)
        }
    }
}

extension ProfileVC {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var avatarImage: UIImage
        
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            avatarImage = possibleImage
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            avatarImage = possibleImage
            
        } else {
            return
        }
        
        
        
        picker.dismiss(animated: true) {
            var imageCropVC: RSKImageCropViewController!
            imageCropVC = RSKImageCropViewController(image: avatarImage, cropMode: .circle)
            imageCropVC.delegate = self
            self.present(imageCropVC, animated: true, completion: nil)
        }
    }
}

extension ProfileVC: RSKImageCropViewControllerDelegate {
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        self.headerView.profilePhotoImageView.image = croppedImage
        dismiss(animated: true, completion: nil)
        
        let imageData = resize(croppedImage)
        pointAdder(numberOfPoints: 10)
        FirebaseController.shared.uploadProfilePhoto(data: imageData!)
    }
    
    func resize(_ image: UIImage) -> Data? {
        var actualHeight = Float(image.size.height)
        var actualWidth = Float(image.size.width)
        let maxHeight: Float = 255.0//933.0
        let maxWidth: Float = 255.0//1242.0
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let compressionQuality: Float = 0.4
        
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = UIImageJPEGRepresentation(img!, CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        return imageData
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        dismiss(animated: true, completion: nil)
    }
}

extension ProfileVC: ProfileHeaderViewDelegate {
    func didTapProfilePhotoButton() {
        
        print("profile photo")
        present(imagePicker!, animated: true, completion: nil)
    }
    
    func didTapSettingsButton() {
        print("settings")
        let settingsVC = SettingsVC()
        settingsVC.bioToSet = self.user?.bio ?? ""
        let navController = UINavigationController(rootViewController: settingsVC)
        self.present(navController, animated: true, completion: nil)
    }
    
    func didTapNotificationsButton() {
        print("notifications")
        let notificationsVC = UserNotificationsVC()
        let navController = UINavigationController(rootViewController: notificationsVC)
        self.present(navController, animated: true, completion: nil)
    }
    
    func didTapPointsButton() {
        print("points")
        let pointsVC = PointsVC()
        let navController = UINavigationController(rootViewController: pointsVC)
        self.present(navController, animated: true, completion: nil)
    }
    
    func didTapBackButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func goToAccountInfo() {
        let settingsVC = SettingsVC()
        let navController = UINavigationController(rootViewController: settingsVC)
        self.present(navController, animated: true) {
            settingsVC.accountVC.bio = self.user?.bio ?? ""
            navController.pushViewController(settingsVC.accountVC, animated: true)
        }
    }
    
    func viewLoadSetup(){
        badgeIncrementor()
        fetchUserInfo()
        
        self.view.sv(emptyDataView, userHasNoRecipesLabel)
        emptyDataView.centerInContainer()
        userHasNoRecipesLabel.centerInContainer().left(20).right(20)
        
        if isMyProfile {
            imagePicker = UIImagePickerController()
            imagePicker!.delegate = self
            imagePicker!.sourceType = .photoLibrary
        }
        
        if let userPoints = user?.points {
            headerView.pointsButton.setTitle("\(userPoints)", for: .normal)
            let title = NSAttributedString(string: "\(userPoints)", attributes: [
                NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
                NSAttributedStringKey.foregroundColor: Color.primaryOrange])
            headerView.pointsButton.setAttributedTitle(title, for: .normal)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshRecipes), name: Notification.Name("RecipeUploaded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchUserInfo), name: Notification.Name("UserInfoUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toggleIndicator), name: Notification.Name("UnreadNotification"), object: nil)
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.collectionView?.backgroundColor = .white
        self.collectionView?.contentInsetAdjustmentBehavior = .never
        self.collectionView?.showsVerticalScrollIndicator = false
        self.collectionView?.register(FavoriteCell.self, forCellWithReuseIdentifier: "recipeCell")
        self.collectionView?.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: sectionHeaderID)
    }
}

extension ProfileVC {
    
    func pointAdder(numberOfPoints: Int) {
                guard let userID = Auth.auth().currentUser?.uid else { return }

            FirebaseController.shared.fetchUserWithUID(uid: userID) { (user) in
                guard let user = user else { return }

                var points = user.points
                let newPoints = user.points != nil ? points! + numberOfPoints : numberOfPoints
                if user.avatarURL == nil || user.avatarURL == "" {
                FirebaseController.shared.ref.child("users").child((user.uid)).child("points").setValue(newPoints)
                }
            }
        }
    func badgeStatusPointAdder(badgeStatusNumber: Int) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        FirebaseController.shared.fetchUserWithUID(uid: userID) { (user) in
            guard let user = user else { return }
            FirebaseController.shared.ref.child("users").child((user.uid)).child("badgeStatus").setValue(badgeStatusNumber)
        }
    }
    
    func moreThanFiftyFavorites(completion: @escaping (Bool)->()) -> Void{
        
        guard let userID = Auth.auth().currentUser?.uid else {return}
        
        FirebaseController.shared.ref.child("users").child(userID).child("uploadedRecipes").observeSingleEvent(of: .value) { (result) in
            for recipe in result.children.allObjects as! [DataSnapshot] {
                
                let recipeUID = recipe.key
                
                FirebaseController.shared.ref.child("recipes").child(recipeUID).child("favoritedBy").observeSingleEvent(of: .value) { (snapshot) in
                    print(snapshot.children.allObjects)
                    
                    if snapshot.childrenCount >= 50 {
                        completion(true)
                    }
                    
                }
            }
            completion(false)
        }
        return
    }
    
    func moreThanTwentyUploadedRecipes(completion: @escaping (Bool)->()) -> Void {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        FirebaseController.shared.ref.child("users").child(userID).child("uploadedRecipes").observe(.value) { (snapshot) in
            if snapshot.childrenCount >= 20 {
                completion(true)
                } else {
                completion(false)
            }

        }
        return
    }
    
    func moreThanTenCooked(completion: @escaping (Bool)->()) -> Void {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        FirebaseController.shared.ref.child("users").child(userID).child("uploadedRecipes").observeSingleEvent(of: .value) { (result) in
            for recipe in result.children.allObjects as! [DataSnapshot] {
                
                let recipeUID = recipe.key
                
                FirebaseController.shared.ref.child("recipes").child(recipeUID).child("cookedImages").observeSingleEvent(of: .value) { (snapshot) in
                    
                    if snapshot.childrenCount >= 10 {
                        completion(true)
                    }
                    
                }
            }
        }
        return
    }
    
    func badgeIncrementor() {
        
        //GOLD

        guard let userID = Auth.auth().currentUser?.uid else {return}
        
        FirebaseController.shared.ref.child("users").child(userID).child("uploadedRecipes").observeSingleEvent(of: .value) { (result) in
            for recipe in result.children.allObjects as! [DataSnapshot] {
                
                let recipeUID = recipe.key
                
                FirebaseController.shared.ref.child("recipes").child(recipeUID).child("favoritedBy").observeSingleEvent(of: .value) { (snapshot) in
                    print(snapshot.children.allObjects)
                    
                    if snapshot.childrenCount >= 50 {
                        FirebaseController.shared.ref.child("users").child(userID).child("uploadedRecipes").observe(.value) { (snapshot) in
                            if snapshot.childrenCount >= 20 {
                                FirebaseController.shared.ref.child("users").child(userID).child("uploadedRecipes").observeSingleEvent(of: .value) { (result) in
                                    for recipe in result.children.allObjects as! [DataSnapshot] {
                                        
                                        let recipeUID = recipe.key
                                        
                                        FirebaseController.shared.ref.child("recipes").child(recipeUID).child("cookedImages").observeSingleEvent(of: .value) { (snapshot) in
                                            
                                            if snapshot.childrenCount >= 10 {
                                                // INCREMENT TO GOLD
                                                self.pointAdder(numberOfPoints: 500)
                                                self.badgeStatusPointAdder(badgeStatusNumber: 3)
                                                
                                                return
                                            }
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
        }
        
        //SILVER
        
        FirebaseController.shared.ref.child("users").child(userID).child("uploadedRecipes").observeSingleEvent(of: .value) { (result) in
            for recipe in result.children.allObjects as! [DataSnapshot] {
                
                let recipeUID = recipe.key
                
                FirebaseController.shared.ref.child("recipes").child(recipeUID).child("favoritedBy").observeSingleEvent(of: .value) { (snapshot) in
                    print(snapshot.children.allObjects)
                    
                    if snapshot.childrenCount >= 20 {
                        FirebaseController.shared.ref.child("users").child(userID).child("uploadedRecipes").observe(.value) { (snapshot) in
                            if snapshot.childrenCount >= 10 {
                                FirebaseController.shared.ref.child("users").child(userID).child("uploadedRecipes").observeSingleEvent(of: .value) { (result) in
                                    for recipe in result.children.allObjects as! [DataSnapshot] {
                                        
                                        let recipeUID = recipe.key
                                        
                                        FirebaseController.shared.ref.child("recipes").child(recipeUID).child("cookedImages").observeSingleEvent(of: .value) { (snapshot) in
                                            
                                            if snapshot.childrenCount >= 5 {
                                                // INCREMENT TO GOLD
                                                self.pointAdder(numberOfPoints: 250)
                                                self.badgeStatusPointAdder(badgeStatusNumber: 2)
                                                
                                                return
                                            }
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
        }
        //BRONZE
        
        FirebaseController.shared.fetchUserWithUID(uid: userID) { (user) in
            guard let user = user else { return }
        
            if user.avatarURL != nil, user.avatarURL != "", user.bio != nil, user.bio != "" {
                FirebaseController.shared.ref.child("users").child(userID).child("uploadedRecipes").observe(.value) { (snapshot) in
                    if snapshot.childrenCount >= 3 {
                        self.pointAdder(numberOfPoints: 100)
                        self.badgeStatusPointAdder(badgeStatusNumber: 1)
                    }
                }
            }
            
    }
}
}







