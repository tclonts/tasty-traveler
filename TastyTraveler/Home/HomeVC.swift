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
import FirebaseAuth
import SVProgressHUD

private let reuseIdentifier = "recipeCell"

class HomeVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var filteredByCountry = [Recipe]()
    var filteredByRecipeName = [Recipe]()
    var filteredByLocality = [Recipe]()
    
    lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        return gesture
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(cancelSearch), for: .touchUpInside)
        button.isHidden = true
        button.alpha = 0
        return button
    }()
    
    lazy var searchField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search recipes"
        textField.borderStyle = .none
        textField.returnKeyType = .search
        textField.font = UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(14))
        textField.textColor = Color.darkText
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = false
        
        textField.layer.shadowRadius = 16
        textField.layer.shadowOffset = CGSize(width: 0, height: 0)
        textField.layer.shadowOpacity = 0.1
        textField.height(adaptConstant(38))
        
        textField.setLeftPadding(amount: adaptConstant(14))
        textField.setRightPadding(amount: adaptConstant(14))
        
        textField.backgroundColor = .white
        return textField
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
    
    lazy var emptyDataView: UIStackView = {
        let label = UILabel()
        label.font = UIFont(name: "ProximaNova-Regular", size: adaptConstant(20))
        label.text = "No Recipes Found"
        label.textColor = Color.gray
        
        let button = UIButton(type: .system)
        let title = NSAttributedString(string: "Remove All Filters", attributes: [
            NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
            NSAttributedStringKey.foregroundColor: Color.primaryOrange])
        button.setAttributedTitle(title, for: .normal)
        button.addTarget(self, action: #selector(clearFilters), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [label, button])
        stackView.axis = .vertical
        stackView.spacing = adaptConstant(20)
        stackView.isHidden = true
        stackView.alpha = 0
        return stackView
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
    
    var searchResultRecipes = [Recipe]()
    var recipes = [Recipe]()
    var lastSearchText = ""
    var isSearching = false
    
    var cancelledSearch = false
    var isCancelButtonShowing = false
    var recipeDataHasChanged = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.keyboardDismissMode = .interactive
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
        notificationCenter.addObserver(self, selector: #selector(handleRefresh), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        //notificationCenter.addObserver(self, selector: #selector(handleRefresh), name: Notification.Name("ReviewsLoaded"), object: nil)
        
//        self.view.insertSubview(loadingRecipesView, belowSubview: collectionView!)
        self.view.sv(loadingRecipesView)
        loadingRecipesView.left(0).right(0)
        loadingRecipesView.centerVertically()
        
        self.collectionView?.delaysContentTouches = true
        
        self.view.sv(emptyDataView)
        emptyDataView.centerInContainer()
        
        fetchAllRecipes()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if recipeDataHasChanged {
            collectionView?.reloadItems(at: [previousIndexPath!])
            recipeDataHasChanged = false
        }
    }
    
    func showFilters() {
        if self.searchField.isFirstResponder { self.searchField.resignFirstResponder() }
        
        filtersLauncher.showFilters()
    }
    
    func showEmptyView() {
        emptyDataView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.emptyDataView.alpha = 1
        }
        print("No recipes found.")
    }
    
    func hideEmptyView() {
        self.emptyDataView.alpha = 0
        self.emptyDataView.isHidden = true
    }
    
    @objc func clearFilters() {
        filtersLauncher.clearFilters()
        filtersLauncher.filtersApplied = false
//        collectionView?.reloadSections([0])
        
        hideEmptyView()
        handleRefresh()
    }
    
    @objc func handleRefresh() {
        hideEmptyView()
        print("Handling refresh..")
        recipes.removeAll()
        //collectionView?.reloadData()
        fetchAllRecipes()
    }
    
    @objc func cancelSearch() {
        print("canceled search")
        isSearching = false
        searchField.text = ""
        lastSearchText = ""
        searchField.resignFirstResponder()
        
        if self.filtersLauncher.filtersApplied {
            self.filtersLauncher.applyFilters()
        } else {
            self.searchResultRecipes = self.recipes
        }
        
        self.hideEmptyView()
        UIView.animate(withDuration: 0.3, animations: {
            self.cancelButton.alpha = 0
        }) { (_) in
            self.cancelButton.isHidden = true
            self.isCancelButtonShowing = false
        }
        cancelButton.removeFromSuperview()
        self.collectionView?.reloadSections([1])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return adaptConstant(20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 1 {
            return UIEdgeInsetsMake(0, 0, adaptConstant(18), 0 )
        } else {
            return UIEdgeInsets.zero
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            if filtersLauncher.filtersApplied {
                return CGSize(width: view.frame.width, height: adaptConstant(165))
            } else {
                return CGSize(width: view.frame.width, height: adaptConstant(125))
            }
        } else {
            return CGSize.zero
        }
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
        if indexPath.section == 0 {
            
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! HomeHeaderView
            
            header.homeVC = self
            header.searchField = searchField
            header.searchField.delegate = self
            header.searchField.addTarget(self, action: #selector(textChanged(textField:)), for: .editingChanged)
            
            header.setUpViews()
            
            if filtersLauncher.filtersApplied {
                header.filterStatusView.isHidden = false
                header.filterStatusView.filtersCollectionView.reloadData()
            } else {
                header.filterStatusView.isHidden = true
            }
            
            return header
        } else {
            return UICollectionReusableView()
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return 0 }
        return searchResultRecipes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RecipeCell
        print(indexPath)
        if searchResultRecipes.count > 0 {
            let recipe = searchResultRecipes[indexPath.item]
            cell.recipe = recipe
            cell.delegate = self
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
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
        recipeDetailVC.homeVC = self
        //recipeDetailVC.formatCookButton()
        recipeDetailVC.recipeHeaderView.photoImageView.loadImage(urlString: recipe.photoURL, placeholder: nil)
        recipeDetailVC.recipeHeaderView.starRating.rating = cell.recipeHeaderView.starRating.rating
        recipeDetailVC.recipeHeaderView.starRating.text = cell.recipeHeaderView.starRating.text
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
            //self.view.removeGestureRecognizer(tapGesture)
            //self.collectionView?.contentInset = UIEdgeInsets.zero
        } else {
            //self.view.addGestureRecognizer(tapGesture)
            //self.collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        //self.collectionView?.scrollIndicatorInsets = self.collectionView!.contentInset
    }
    
    @objc func handleTap() {
        searchField.resignFirstResponder()
        searchField.layoutIfNeeded()
    }
}

extension HomeVC {
    func fetchAllRecipes() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        //loadingRecipesView.isHidden = (self.collectionView?.refreshControl?.isRefreshing)!
        
        var incomingRecipes = [Recipe]()
        
        
        FirebaseController.shared.ref.child("recipes").observeSingleEvent(of: .value) { (snapshot) in
            
            // Stop refreshing & loading indicators
            self.collectionView?.refreshControl?.endRefreshing()
            
            guard let recipeIDsDictionary = snapshot.value as? [String:Any] else { return }
            guard let userID = Auth.auth().currentUser?.uid else { return }
            
            let group = DispatchGroup()
            
            recipeIDsDictionary.forEach({ (key, value) in
                guard let recipeDictionary = value as? [String:Any] else { return }
                guard let creatorID = recipeDictionary[Recipe.creatorIDKey] as? String, creatorID != userID else { return }
                
                group.enter()
                
                FirebaseController.shared.fetchUserWithUID(uid: creatorID, completion: { (creator) in
                    guard let creator = creator else { group.leave(); return }
                    
                    var recipe = Recipe(uid: key, creator: creator, dictionary: recipeDictionary)
                    
                    FirebaseController.shared.ref.child("users").child(userID).child("favorites").child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                        if (snapshot.value as? Double) != nil {
                            recipe.hasFavorited = true
                        } else {
                            recipe.hasFavorited = false
                        }
                        
                        FirebaseController.shared.ref.child("users").child(userID).child("cookedRecipes").child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                            if (snapshot.value as? Double) != nil {
                                recipe.hasCooked = true
                                let timestamp = (snapshot.value as! Double)
                                recipe.cookedDate = Date(timeIntervalSince1970: timestamp)
                            } else {
                                recipe.hasCooked = false
                            }
                            
                            incomingRecipes.append(recipe)
                            
                            group.leave()
                        
                        })
                        
                        
                    }, withCancel: { (error) in
                        print("Failed to fetch favorite info for recipe: ", error)
                    })
                    
                })
            })
            
            group.notify(queue: .main) {
                self.recipes = incomingRecipes
                self.recipes.sort(by: { (r1, r2) -> Bool in
                    if r1.recipeScore == r2.recipeScore {
                        return r1.creationDate.compare(r2.creationDate) == .orderedDescending
                    } else {
                        return r1.recipeScore > r2.recipeScore
                    }
                })
                
                if self.lastSearchText != "" {
                    self.searchRecipes(text: self.lastSearchText)
                } else {
                    self.searchResultRecipes = self.recipes
                }
                
                self.collectionView?.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                //self.loadingRecipesView.isHidden = true
                
                if self.filtersLauncher.filtersApplied {
                    self.filtersLauncher.applyFilters()
                    //                        self.filterStatusView.filtersCollectionView.reloadData()
                    //                        self.filterStatusView.isHidden = false
                }
                
                self.searchResultRecipes.isEmpty ? self.showEmptyView() : self.hideEmptyView()
            }
        }
    }
    
    func openMapView() {
        let mapView = RecipesMapView()
        if filtersLauncher.filtersApplied || lastSearchText != "" {
            mapView.filteredRecipes = self.searchResultRecipes
        }
        self.navigationController?.pushViewController(mapView, animated: true)
    }
}

extension HomeVC: UITextFieldDelegate {
    @objc func textChanged(textField: UITextField) {
        if let text = textField.text {
            print(text)
            if text.isEmpty {
                //isSearching = false
                
                //self.collectionView?.reloadSections([1])
                
                if textField.subviews.contains(cancelButton) {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.cancelButton.alpha = 0
                    }, completion: { (_) in
                        self.cancelButton.isHidden = true
                        self.cancelButton.removeFromSuperview()
                    })
                    isCancelButtonShowing = false
                }
                return
            }
            
            if !textField.subviews.contains(cancelButton) {
                textField.sv(cancelButton)
            }
            
            if !isCancelButtonShowing {
                cancelButton.right(adaptConstant(12))
                cancelButton.centerVertically()
                cancelButton.isHidden = false
                UIView.animate(withDuration: 0.3, animations: {
                    self.cancelButton.alpha = 1
                })
                isCancelButtonShowing = true
            }
           
        }
    }
    
    func calculateSearchScore(recipe: Recipe, text: [String]) -> Int {
        var nameCount = 0
        var countryCount = 0
        var localityCount = 0
        
        text.forEach { word in
            let nameWords = recipe.name.lowercased().components(separatedBy: " ")
            let nameMatches = nameWords.filter { $0 == word }.count
            nameCount += nameMatches
            
//            let nameDifference = nameWords.count - nameMatches
//            if nameDifference > 0 { nameCount -= nameDifference }
            
            if recipe.country != nil {
                let countryWords = recipe.country!.lowercased().components(separatedBy: " ")
                let countryMatches = countryWords.filter { $0 == word }.count
                countryCount += countryMatches
                
//                let countryDifference = countryWords.count - countryMatches
//                if countryDifference > 0 { countryCount -= countryDifference }
            }
            
            if recipe.locality != nil {
                let localityWords = recipe.locality!.lowercased().components(separatedBy: " ")
                let localityMatches = localityWords.filter { $0 == word }.count
                localityCount += localityMatches
                
//                let localityDifference = localityWords.count - localityMatches
//                if localityDifference > 0 { localityCount -= localityDifference }
            }
        }
        
        return nameCount + countryCount + localityCount
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("RETURN: " + textField.text!)
        textField.resignFirstResponder()
        textField.layoutIfNeeded()
        if let text = textField.text, text != "" {
            isSearching = true
            searchRecipes(text: text)
        } else {
            self.hideEmptyView()
            self.lastSearchText = ""
            isSearching = false
            if self.filtersLauncher.filtersApplied {
                self.filtersLauncher.applyFilters()
            } else {
                self.searchResultRecipes = self.recipes
            }
            self.collectionView?.reloadSections([1])
        }
        
        return true
    }
    
    func searchRecipes(text: String) {
        
        let splitText = text.lowercased().components(separatedBy: " ")
        
        if filtersLauncher.filtersApplied {
            let matchingRecipes = searchResultRecipes.filter { calculateSearchScore(recipe: $0, text: splitText) > 0 }
            
            self.searchResultRecipes = matchingRecipes.sorted(by: { (r1, r2) -> Bool in
                calculateSearchScore(recipe: r1, text: splitText) > calculateSearchScore(recipe: r2, text: splitText)
            })
            
        } else {
            let matchingRecipes = recipes.filter { calculateSearchScore(recipe: $0, text: splitText) > 0 }
            
            self.searchResultRecipes = matchingRecipes.sorted(by: { (r1, r2) -> Bool in
                calculateSearchScore(recipe: r1, text: splitText) > calculateSearchScore(recipe: r2, text: splitText)
            })

        }
        
        self.collectionView?.reloadSections([1])
        self.lastSearchText = text
        self.searchResultRecipes.isEmpty ? showEmptyView() : hideEmptyView()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.subviews.contains(cancelButton) && textField.text == "" {
            UIView.animate(withDuration: 0.3, animations: {
                self.cancelButton.alpha = 0
            }, completion: { (_) in
                self.cancelButton.isHidden = true
            })
            isCancelButtonShowing = false
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        if cancelledSearch { cancelledSearch = false; return true }
//        self.collectionView?.isScrollEnabled = false
//        let searchVC = SearchVC()
//        addChildViewController(searchVC)
////        searchVC.view.frame = CGRect(x: view.bounds.minX, y: adaptConstant(125), width: view.bounds.width, height: view.bounds.height - adaptConstant(125))
//        //view.addSubview(searchVC.view)
//        let y = textField.superview!.frame.maxY
//        print(y)
//        searchVC.view.frame = CGRect(x: view.bounds.minX, y: y, width: view.bounds.width, height: view.bounds.height - y)
//        if let searchField = textField as? CustomSearchField {
//            searchField.homeHeaderView?.searchVC = searchVC
//            searchField.homeHeaderView?.cancelButton.isHidden = false
//            UIView.animate(withDuration: 0.3, animations: {
//                searchField.homeHeaderView?.cancelButton.alpha = 1
//            })
//        }
//        view.addSubview(searchVC.view)
//        searchVC.didMove(toParentViewController: self)
//        searchVC.homeVC = self
        
        
        
        //NotificationCenter.default.post(name: Notification.Name("handleTextChangeNotification"), object: nil, userInfo: ["text": textField.text!])
        
        return true
    }
}

extension HomeVC: RecipeCellDelegate {
    func didTapFavorite(for cell: RecipeCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        
        var recipe = self.searchResultRecipes[indexPath.item]
        
        let recipeID = recipe.uid
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        if recipe.hasFavorited {
            // remove
            FirebaseController.shared.ref.child("recipes").child(recipeID).child("favoritedBy").child(userID).removeValue()
            FirebaseController.shared.ref.child("users").child(userID).child("favorites").child(recipeID).removeValue()
            
            SVProgressHUD.showError(withStatus: "Removed")
            SVProgressHUD.dismiss(withDelay: 1)
            
            recipe.hasFavorited = false
            
            self.searchResultRecipes[indexPath.item] = recipe
            
            self.collectionView?.reloadItems(at: [indexPath])
            
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
                    
                    recipe.hasFavorited = true
                    
                    self.searchResultRecipes[indexPath.item] = recipe
                    
                    self.collectionView?.reloadItems(at: [indexPath])
                    
                    NotificationCenter.default.post(name: Notification.Name("FavoritesChanged"), object: nil)
                }
            }
        }
    }
}

class SearchVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableView = UITableView()
    var searchResults = [Recipe]()
    var homeVC: HomeVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange(_:)), name: Notification.Name("handleTextChangeNotification"), object: nil)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.sv(tableView)
        
        tableView.fillContainer()
    }
    
    @objc func handleTextChange(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let text = userInfo["text"] as? String {
                searchResults = homeVC!.recipes.filter { (recipe) -> Bool in
                    return recipe.name.lowercased().contains(text.lowercased())
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func updateSearchResults() {
        
    }
    
    func loadMore() {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = searchResults[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recipe = searchResults[indexPath.row]
        
        print(recipe.name)
    }
}
