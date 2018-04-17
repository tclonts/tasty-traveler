//
//  HomeVC.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/14/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia
import Hero

private let reuseIdentifier = "recipeCell"

class HomeVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        return gesture
    }()
    
    lazy var testView: UICollectionReusableView = {
        let view = UICollectionReusableView()
        view.backgroundColor = .red
        return view
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
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    lazy var filtersLauncher: FiltersLauncher = {
        let launcher = FiltersLauncher()
        launcher.homeVC = self
        return launcher
    }()
    
    var recipes = [Recipe]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor.white
        statusBarView.backgroundColor = statusBarColor
        view.sv(statusBarView)
        
        self.collectionView!.register(RecipeCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.register(HomeHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        self.collectionView?.refreshControl = refreshControl
        
        self.navigationController?.navigationBar.isHidden = true
        self.isHeroEnabled = true
        
        self.view.backgroundColor = .white
        self.collectionView?.backgroundColor = .white
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleRefresh), name: Notification.Name("RecipeUploaded"), object: nil)
        
//        self.view.insertSubview(loadingRecipesView, belowSubview: collectionView!)
        self.view.sv(loadingRecipesView)
        loadingRecipesView.left(0).right(0)
        loadingRecipesView.centerVertically()
        
        fetchAllRecipes()
    }
    
    @objc func handleRefresh() {
        print("Handling refresh..")
        recipes.removeAll()
        //collectionView?.reloadData()
        fetchAllRecipes()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return adaptConstant(20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, adaptConstant(18), 0 )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: adaptConstant(125))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - adaptConstant(36) // margins
        if !recipes.isEmpty {
            let recipe = self.recipes[indexPath.row]
            let approximateWidthOfRecipeNameLabel = view.frame.width - adaptConstant(18) - adaptConstant(18) - adaptConstant(20)
            let size = CGSize(width: approximateWidthOfRecipeNameLabel, height: 1000)
            let attributes = [NSAttributedStringKey.font: UIFont(name: "ProximaNova-Bold", size: adaptConstant(22))!]
            let estimatedFrame = NSString(string: recipe.name).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)

            
            return CGSize(width: width, height: estimatedFrame.height + (width * 0.75) + adaptConstant(80))
        } else {
            return CGSize(width: width, height: width)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! HomeHeaderView
        
//        header.homeVC = self
        header.searchField.delegate = self
        
        return header
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return recipes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RecipeCell
        
        if recipes.count > 0 {
            let recipe = recipes[indexPath.item]
            cell.recipe = recipe
        }
        
        return cell
    }
    
    var previousIndexPath: IndexPath?
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let previousIndexPath = previousIndexPath {
            if let previousCell = collectionView.cellForItem(at: previousIndexPath) as? RecipeCell {
                previousCell.recipeHeaderView.heroID = ""
            }
        }
        
        previousIndexPath = indexPath
        
        let cell = collectionView.cellForItem(at: indexPath) as! RecipeCell
        cell.recipeHeaderView.heroID = "recipeHeaderView"
        
        guard let recipe = cell.recipe else { return }
        
        let recipeDetailVC = RecipeDetailVC()
        recipeDetailVC.recipe = recipe
        recipeDetailVC.recipeHeaderView.photoImageView.image = cell.recipeHeaderView.photoImageView.image
        // matching IDs for: Photo, favoriteButton, flagImageView, countryLabel, creatorLabel, ratingsStars, numberOfRatingsLabel
        
        let recipeNavigationController = UINavigationController(rootViewController: recipeDetailVC)
        recipeNavigationController.isHeroEnabled = true
        recipeNavigationController.navigationBar.isHidden = true
        self.present(recipeNavigationController, animated: true, completion: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
//        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
//
        if notification.name == Notification.Name.UIKeyboardWillHide {
            self.view.removeGestureRecognizer(tapGesture)
            //self.collectionView?.contentInset = UIEdgeInsets.zero
        } else {
            self.view.addGestureRecognizer(tapGesture)
            //self.collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        //self.collectionView?.scrollIndicatorInsets = self.collectionView!.contentInset
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
}

extension HomeVC {
    func fetchAllRecipes() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        loadingRecipesView.isHidden = (self.collectionView?.refreshControl?.isRefreshing)!
        
        FirebaseController.shared.ref.child("recipes").observeSingleEvent(of: .value) { (snapshot) in
            
            // Stop refreshing & loading indicators
            self.collectionView?.refreshControl?.endRefreshing()
            
            guard let recipeIDsDictionary = snapshot.value as? [String:Any] else { return }
            
            recipeIDsDictionary.forEach({ (key, value) in
                guard let recipeDictionary = value as? [String:Any] else { return }
                guard let creatorID = recipeDictionary[Recipe.creatorIDKey] as? String else { return }
                
                FirebaseController.shared.fetchUserWithUID(uid: creatorID, completion: { (creator) in
                    var recipe = Recipe(creator: creator, dictionary: recipeDictionary)
                    recipe.uid = key
                    
                    self.recipes.append(recipe)
                    self.recipes.sort(by: { (r1, r2) -> Bool in
                        return r1.creationDate.compare(r2.creationDate) == .orderedDescending
                    })
                    self.collectionView?.reloadData()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.loadingRecipesView.isHidden = true
                })
                
                
            })
        }
    }
}

extension HomeVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
}
