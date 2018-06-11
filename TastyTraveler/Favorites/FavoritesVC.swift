//
//  FavoritesVC.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/14/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import FirebaseAuth
import Stevia
import SVProgressHUD

private let reuseIdentifier = "favoriteCell"

class FavoritesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var searchResultFavorites = [Recipe]()
    var favorites = [Recipe]() {
        didSet {
            if favorites.isEmpty && self.loadingRecipesView.isHidden {
                self.showEmptyView()
            } else {
                self.hideEmptyView()
            }
        }
    }
    
    var isSearching = false
    var itemSize = CGSize.zero
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    let activityIndicator:  UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.color = Color.primaryOrange
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    lazy var loadingRecipesView: UIStackView = {
        let containerView = UIStackView()
        let label = UILabel()
        
        label.text = "Loading recipes"
        label.font = UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(16))
        
        containerView.addArrangedSubview(activityIndicator)
        containerView.addArrangedSubview(label)
        containerView.axis = .vertical
        containerView.alignment = .center
        containerView.spacing = adaptConstant(8)
        containerView.isHidden = true
        
        return containerView
    }()
    
    lazy var emptyDataView: UIStackView = {
        let label = UILabel()
        label.font = UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(20))
        label.text = "You don't have any recipes saved."
        label.textColor = Color.gray
        
        let button = UIButton(type: .system)
        let title = NSAttributedString(string: "Explore Recipes", attributes: [
            NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
            NSAttributedStringKey.foregroundColor: Color.primaryOrange])
        button.setAttributedTitle(title, for: .normal)
        button.addTarget(self, action: #selector(exploreRecipesTapped), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [label, button])
        stackView.axis = .vertical
        stackView.spacing = adaptConstant(20)
        stackView.isHidden = true
        stackView.alpha = 0
        return stackView
    }()
    
    lazy var searchNotFoundView: UIStackView = {
        let label = UILabel()
        label.font = UIFont(name: "ProximaNova-Regular", size: adaptConstant(20))
        label.text = "No recipes found."
        label.textColor = Color.gray
        
        let button = UIButton(type: .system)
        let title = NSAttributedString(string: "Clear Search", attributes: [
            NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
            NSAttributedStringKey.foregroundColor: Color.primaryOrange])
        button.setAttributedTitle(title, for: .normal)
        button.addTarget(self, action: #selector(clearSearchTapped), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [label, button])
        stackView.axis = .vertical
        stackView.spacing = adaptConstant(20)
        stackView.alpha = 0
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.isHeroEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshFavorites), name: Notification.Name("FavoritesChanged"), object: nil)

        extendedLayoutIncludesOpaqueBars = true
        
        self.collectionView.backgroundColor = .white
        self.collectionView.register(FavoriteCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        let tabbarHeight = self.tabBarController!.tabBar.frame.height
        self.collectionView.contentInset = UIEdgeInsets(top: adaptConstant(10), left: adaptConstant(10), bottom: tabbarHeight + adaptConstant(10), right: adaptConstant(10))
        
        self.navigationItem.title = "Favorites"
//        self.navigationController?.navigationBar.prefersLargeTitles = true
//        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: Color.blackText, NSAttributedStringKey.font: UIFont(name: "ProximaNova-Bold", size: adaptConstant(27))!]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Color.blackText, NSAttributedStringKey.font: UIFont(name: "ProximaNova-Bold", size: adaptConstant(20))!]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = .white
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Favorites"
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        self.view.sv(collectionView, emptyDataView, loadingRecipesView)
        
        emptyDataView.centerInContainer()
        loadingRecipesView.centerInContainer()
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
            ])
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            itemSize = flowLayout.itemSize
        }
        
        refreshFavorites()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @objc func refreshFavorites() {
        if self.favorites.isEmpty { self.loadingRecipesView.isHidden = false }
        self.favorites.removeAll()
        fetchFavorites()
    }
    
    @objc func exploreRecipesTapped() {
        print("Explore recipes tapped")
        tabBarController?.selectedIndex = 0
    }
    
    @objc func clearSearchTapped() {
        print("Clear search tapped")
    }
    
    func showEmptyView() {
        emptyDataView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.emptyDataView.alpha = 1
        }
        print("No favorites found.")
    }
    
    func hideEmptyView() {
        self.emptyDataView.alpha = 0
        self.emptyDataView.isHidden = true
    }
    
    func fetchFavorites() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var incomingFavorites = [Recipe]()
        
        FirebaseController.shared.ref.child("users").child(userID).child("favorites").observeSingleEvent(of: .value) { (snapshot) in
            guard let favoriteRecipesDictionary = snapshot.value as? [String:Double] else {
                self.collectionView.reloadData()
                self.favorites.isEmpty ? self.showEmptyView() : self.hideEmptyView()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.loadingRecipesView.isHidden = true
                return
            }
            
            let group = DispatchGroup()
            
            favoriteRecipesDictionary.forEach({ (key, value) in
                group.enter()
                
                FirebaseController.shared.ref.child("recipes").child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let recipeDictionary = snapshot.value as? [String:Any] else { group.leave(); return }
                    guard let creatorID = recipeDictionary[Recipe.creatorIDKey] as? String else { group.leave(); return }
                    
                    FirebaseController.shared.fetchUserWithUID(uid: creatorID, completion: { (creator) in
                        guard let creator = creator else { return }
                        
                        var recipe = Recipe(uid: key, creator: creator, dictionary: recipeDictionary)
                        recipe.favoritedDate = Date(timeIntervalSince1970: value)
                        recipe.hasFavorited = true
                        
                        incomingFavorites.append(recipe)
                        group.leave()
//                        self.favorites.sort(by: { (r1, r2) -> Bool in
//                            return r1.favoritedDate!.compare(r2.favoritedDate!) == .orderedDescending
//                        })
//
//                        self.collectionView.reloadData()
//                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                        self.loadingRecipesView.isHidden = true
                    })
                })
            })
            
            group.notify(queue: .main) {
                self.favorites = incomingFavorites
                self.favorites.sort(by: { (r1, r2) -> Bool in
                    return r1.favoritedDate!.compare(r2.favoritedDate!) == .orderedDescending
                })
                
                self.collectionView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.loadingRecipesView.isHidden = true
            }
        }
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching ? searchResultFavorites.count : favorites.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FavoriteCell
        
        cell.recipe = isSearching ? searchResultFavorites[indexPath.item] : favorites[indexPath.item]
        cell.delegate = self
//        cell.clipsToBounds = false
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! FavoriteCell

        guard let recipe = cell.recipe else { return }
        
        let recipeDetailVC = RecipeDetailVC()
        recipeDetailVC.recipe = recipe
        //recipeDetailVC.formatCookButton()
        recipeDetailVC.recipeHeaderView.photoImageView.loadImage(urlString: recipe.photoURL, placeholder: nil)

        
        let recipeNavigationController = UINavigationController(rootViewController: recipeDetailVC)
//        self.isHeroEnabled = true
        recipeNavigationController.navigationBar.isHidden = true
//        recipeNavigationController.isHeroEnabled = true
        
        recipeDetailVC.isFromFavorites = true
        
        self.present(recipeNavigationController, animated: true, completion: nil)
    }
}

extension FavoritesVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            self.searchResultFavorites = self.favorites.filter({ (recipe) -> Bool in
                return recipe.name.lowercased().contains(text.lowercased())
            })
            self.isSearching = true
            
//            if self.searchResultFavorites.isEmpty {
//                self.collectionView.sv(searchNotFoundView)
//                searchNotFoundView.centerInContainer()
//            } else {
//                searchNotFoundView.removeFromSuperview()
//            }
        } else {
            self.searchResultFavorites = [Recipe]()
            self.isSearching = false
        }
        
        self.collectionView.reloadData()
    }
}

extension FavoritesVC: FavoriteCellDelegate {
    func didTapFavorite(for cell: FavoriteCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }

        let recipe = isSearching ? self.searchResultFavorites[indexPath.item] : self.favorites[indexPath.item]

        let recipeID = recipe.uid

        guard let userID = Auth.auth().currentUser?.uid else { return }

        // remove
        FirebaseController.shared.ref.child("recipes").child(recipeID).child("favoritedBy").child(userID).removeValue()
        FirebaseController.shared.ref.child("users").child(userID).child("favorites").child(recipeID).removeValue()
        
        if isSearching {
            let favoritesIndex = self.favorites.index(where: { (r) -> Bool in
                r.uid == recipe.uid
            })
            
            self.searchResultFavorites.remove(at: indexPath.item)
            self.favorites.remove(at: favoritesIndex!)
            self.collectionView.deleteItems(at: [indexPath])
            
            
        } else {
            
            self.favorites.remove(at: indexPath.item)
            self.collectionView.deleteItems(at: [indexPath])
        }

        SVProgressHUD.showError(withStatus: "Removed")
        SVProgressHUD.dismiss(withDelay: 1)
        
        NotificationCenter.default.post(name: Notification.Name("RecipeUploaded"), object: nil)
    }
}

class FavoriteCell: BaseCell {
    
    var recipe: Recipe? {
        didSet {
            backgroundImageView.loadImage(urlString: recipe!.photoURL, placeholder: nil)
            
            recipeNameLabel.text = recipe?.name
            
            if let meal = recipe?.meal {
                self.mealLabel.text = "  \(meal)  "
            }
        }
    }
    
    lazy var shadowView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = adaptConstant(12)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: adaptConstant(10))
        view.layer.shadowRadius = adaptConstant(25)
        view.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        return view
    }()
    
    let placeHolderImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "imagePlaceholder"))
        imageView.width(adaptConstant(65))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let backgroundImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.02)
        return imageView
    }()
    
//    let mealLabel: UIButton = {
//        let button = UIButton(type: .system)
//        button.backgroundColor = Color.primaryOrange
//        button.layer.cornerRadius = adaptConstant(10)
//        button.clipsToBounds = true
//        button.layer.masksToBounds = true
//        button.isUserInteractionEnabled = false
//        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: adaptConstant(6), bottom: 0, right: adaptConstant(8))
//        button.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
//        return button
//    }()
    
    let mealLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = Color.primaryOrange
        label.layer.cornerRadius = adaptConstant(10)
        label.clipsToBounds = true
        label.layer.masksToBounds = true
        label.font = UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(12))
        label.textColor = .white
        label.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        return label
    }()
    
    let gradientView: GradientView = {
        let gradient = GradientView()
        gradient.cornerRadius = adaptConstant(12)
        return gradient
    }()
    
    let recipeNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(16))
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.width(34).height(34)
        button.setImage(#imageLiteral(resourceName: "favoriteButtonSelected"), for: .normal)
        button.layer.shadowOpacity = 0.16
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = adaptConstant(13)
        button.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: FavoriteCellDelegate?
    
    override func setUpViews() {
        sv(shadowView.sv(placeHolderImageView, backgroundImageView, gradientView, recipeNameLabel, favoriteButton, mealLabel))
        
        shadowView.fillContainer()
        
        placeHolderImageView.centerInContainer()
        
        backgroundImageView.fillContainer()
        backgroundImageView.layer.cornerRadius = adaptConstant(12)
        backgroundImageView.clipsToBounds = true
        backgroundImageView.layer.masksToBounds = true
        
        gradientView.left(0).right(0).bottom(0).height(self.frame.height / 2)
        gradientView.startPointX = 0.5
        gradientView.startPointY = 0
        gradientView.endPointX = 0.5
        gradientView.endPointY = 1
        gradientView.bottomColor = UIColor.black.withAlphaComponent(0.64)
        gradientView.topColor = UIColor.black.withAlphaComponent(0)
        
        recipeNameLabel.left(adaptConstant(8)).right(adaptConstant(8)).bottom(adaptConstant(8))
        
        favoriteButton.top(adaptConstant(8)).right(adaptConstant(8))
        
        mealLabel.left(0)
        mealLabel.CenterY == favoriteButton.CenterY
        mealLabel.height(adaptConstant(20))
    }
    
    @objc func favoriteButtonTapped() {
        delegate?.didTapFavorite(for: self)
    }
    
    override func prepareForReuse() {
        
    }
}

protocol FavoriteCellDelegate: class {
    func didTapFavorite(for cell: FavoriteCell)
}
