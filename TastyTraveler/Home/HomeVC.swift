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
import Firebase
import FacebookCore

private let reuseIdentifier = "recipeCell"

class HomeVC: UITableViewController {
    
    var filteredByCountry = [Recipe]()
    var filteredByRecipeName = [Recipe]()
    var filteredByLocality = [Recipe]()
    
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

    let activityIndicator:  UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.color = Color.primaryOrange
        activityIndicator.startAnimating()
        return activityIndicator
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
    
    var previousIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        pointUpToSpeed()
        
        self.view.backgroundColor = .white
        self.isHeroEnabled = true
        self.navigationController?.navigationBar.isHidden = true
        
        
        // Tableview Setup
        self.refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.tableView.keyboardDismissMode = .interactive
        self.tableView.register(RecipeCell.self, forCellReuseIdentifier: reuseIdentifier)
        self.tableView.register(HomeHeaderView.self, forCellReuseIdentifier: "header")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200
        self.tableView.backgroundColor = .white
        self.tableView.separatorStyle = .none
        
        // Notifications
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleRefresh), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: Notification.Name("RecipeUploaded"), object: nil)
        
        self.view.sv(emptyDataView)
        emptyDataView.centerInContainer()
        
        fetchAllRecipes()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if recipeDataHasChanged {
            tableView.reloadRows(at: [previousIndexPath!], with: .none)
            recipeDataHasChanged = false
        }
    }
    
    func showFilters() {
        if self.searchField.isFirstResponder { self.searchField.resignFirstResponder() }
        
        filtersLauncher.showFilters()
    }
    
    var sortQuery: String?
    var currentlySortingBy = "Random"
    
    func showSort() {
        let ac = UIAlertController(title: "Sort Recipes", message: "Currently sorted by: \(self.currentlySortingBy)", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Highest Rated", style: .default, handler: { (_) in
            print("Sort by highest rated")
            self.sortQuery = "recipeScore"
            self.currentlySortingBy = "Highest Rated"
            self.handleRefresh()
        }))
        ac.addAction(UIAlertAction(title: "Newest", style: .default, handler: { (_) in
            print("Sort by newest")
            self.sortQuery = "timestamp"
            self.currentlySortingBy = "Newest"
            self.handleRefresh()
        }))
        ac.addAction(UIAlertAction(title: "Most Cooked", style: .default, handler: { (_) in
            print("Sort by most cooked")
            self.sortQuery = "reviews"
            self.currentlySortingBy = "Most Cooked"
            self.handleRefresh()
        }))
        ac.addAction(UIAlertAction(title: "Random", style: .default, handler: { (_) in
            print("Sort by random")
            self.sortQuery = nil
            self.currentlySortingBy = "Random"
            self.handleRefresh()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(ac, animated: true, completion: nil)
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
        
        hideEmptyView()
        handleRefresh()
    }
    
    var isRefreshing = false
    
    @objc func handleRefresh() {
        hideEmptyView()
        print("Handling refresh..")
        self.tableView.refreshControl?.beginRefreshing()
        isRefreshing = true
        recipes.removeAll()
        refreshPage = 25
        fetchAllRecipes()
    }
    
    @objc func cancelSearch() {
        print("canceled search")
        isSearching = false
        searchField.text = ""
        lastSearchText = ""
        searchField.resignFirstResponder()
        
        sortData()
        self.hideEmptyView()
        
        if self.filtersLauncher.filtersApplied {
            self.filtersLauncher.applyFilters()
        } else {
            self.searchResultRecipes = Array(self.recipes.prefix(25))
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.cancelButton.alpha = 0
        }) { (_) in
            self.cancelButton.isHidden = true
            self.isCancelButtonShowing = false
        }
        cancelButton.removeFromSuperview()
//        self.tableView.reloadSections([1], with: .automatic)
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        return searchResultRecipes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let header = tableView.dequeueReusableCell(withIdentifier: "header", for: indexPath) as! HomeHeaderView
            
            header.homeVC = self
            header.searchField = searchField
            header.searchField.delegate = self
            header.searchField.addTarget(self, action: #selector(textChanged(textField:)), for: .editingChanged)
            
            header.setUpViews()
            
            if filtersLauncher.filtersApplied {
                header.filterStatusView.isHidden = false
                header.filterStatusView.filtersCollectionView.collectionViewLayout.invalidateLayout()
                header.filterStatusView.filtersCollectionView.reloadData()
                header.filterStatusView.filtersCollectionView.setNeedsLayout()
                header.filterStatusView.filtersCollectionView.layoutIfNeeded()
            } else {
                header.filterStatusView.filtersCollectionView.collectionViewLayout.invalidateLayout()
                header.filterStatusView.filtersCollectionView.reloadData()
                header.filterStatusView.filtersCollectionView.setNeedsLayout()
                header.filterStatusView.filtersCollectionView.layoutIfNeeded()
                header.filterStatusView.isHidden = true
            }
            
            return header
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! RecipeCell
            
            if searchResultRecipes.count > 0 {
                let recipe = searchResultRecipes[indexPath.item]
                cell.recipe = recipe
                cell.delegate = self
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
            }
            
            return cell
        }
    }
    
    var filteredRecipes = [Recipe]()
    
    var loadingData = false
    var refreshPage = 25
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !loadingData && indexPath.row == refreshPage - 1 {
            loadingData = true
            loadMore()
        }
    }
    
    func loadMore() {
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                self.refreshPage += 25
                if self.isSearching || self.filtersLauncher.filtersApplied {
                    self.searchResultRecipes = Array(self.filteredRecipes.prefix(self.refreshPage))
                } else {
                    self.searchResultRecipes = Array(self.recipes.prefix(self.refreshPage))
                }
                self.tableView.reloadData()
                self.loadingData = false
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { return }
        if let previousIndexPath = previousIndexPath {
            if let previousCell = tableView.cellForRow(at: previousIndexPath) as? RecipeCell {
                previousCell.recipeHeaderView.heroID = ""
            }
        }
        
        previousIndexPath = indexPath
        
        let cell = tableView.cellForRow(at: indexPath) as! RecipeCell
        cell.recipeHeaderView.heroID = "recipeHeaderView"
        
        guard let recipe = cell.recipe else { return }
        
        let recipeDetailVC = RecipeDetailVC()
        recipeDetailVC.recipe = recipe
        recipeDetailVC.homeVC = self
        recipeDetailVC.recipeHeaderView.photoImageView.loadImage(urlString: recipe.photoURL, placeholder: nil)
        recipeDetailVC.recipeHeaderView.starRating.rating = cell.recipeHeaderView.starRating.rating
        recipeDetailVC.recipeHeaderView.starRating.text = cell.recipeHeaderView.starRating.text
        
        let recipeNavigationController = UINavigationController(rootViewController: recipeDetailVC)
        recipeNavigationController.isHeroEnabled = true
        recipeNavigationController.navigationBar.isHidden = true
        self.present(recipeNavigationController, animated: true, completion: nil)
    }
    
    var incomingRecipes = [Recipe]()

}

extension HomeVC {
    func fetchAllRecipes() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        SVProgressHUD.show(withStatus: "Loading Recipes")
        
        let ref = FirebaseController.shared.ref.child("recipes")
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            self.incomingRecipes.removeAll()
            self.createRecipes(from: snapshot)
        }
    }
    
    
    
    
    func getRecipeData(forDict recipeDictionary: [String:Any], key: String, group: DispatchGroup) {
        guard let creatorID = recipeDictionary[Recipe.creatorIDKey] as? String else { return }
        
        group.enter()
        
        FirebaseController.shared.fetchUserWithUID(uid: creatorID, completion: { (creator) in
            guard let creator = creator else {
                group.leave()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.tableView.refreshControl?.endRefreshing()
                SVProgressHUD.dismiss()
                self.isRefreshing = false
                return
            }
            
            var recipe = Recipe(uid: key, creator: creator, dictionary: recipeDictionary)
            
            if let browsing = UserDefaults.standard.value(forKey: "isBrowsing") as? Bool, browsing {
                recipe.hasFavorited = false
                recipe.hasCooked = false
                self.incomingRecipes.append(recipe)
                group.leave()
                
            } else {
                guard let userID = Auth.auth().currentUser?.uid else { return }

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
                        
                        self.incomingRecipes.append(recipe)
                        
                        group.leave()
                        
                    })
                    
                    
                }, withCancel: { (error) in
                    print("Failed to fetch favorite info for recipe: ", error)
                    group.leave()
                })
            }
        })
    }
    
    
    func createRecipes(from snapshot: DataSnapshot) {
        
        //self.tableView.refreshControl?.endRefreshing()
        
        guard let recipeIDsDictionary = snapshot.value as? [String:Any] else { return }
        let group = DispatchGroup()
        
        recipeIDsDictionary.forEach({ (key, value) in
            guard let recipeDictionary = value as? [String:Any] else { return }
            getRecipeData(forDict: recipeDictionary, key: key, group: group)
        })
        
        group.notify(queue: .main) {
            if !self.incomingRecipes.isEmpty {
                self.updateData()
            }
        }
    }
    
    func updateData() {
        // First load or when handling a refresh
        
        self.recipes = incomingRecipes
        
        if self.lastSearchText != "" {
            self.searchRecipes(text: self.lastSearchText)
        } else {
            sortData()            
        }
        
        if self.filtersLauncher.filtersApplied {
            self.filtersLauncher.applyFilters()
        }
        
        if !self.filtersLauncher.filtersApplied && self.lastSearchText == "" {
            self.searchResultRecipes = Array(self.recipes.prefix(25))
            self.tableView.reloadData()
            
            self.searchResultRecipes.isEmpty ? self.showEmptyView() : self.hideEmptyView()
        }
        
        self.tableView.refreshControl?.endRefreshing()
        isRefreshing = false
        SVProgressHUD.dismiss()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        self.incomingRecipes.removeAll()
    }
    
    func sortData() {
        if let query = self.sortQuery {
            switch query {
            case "timestamp":
                self.recipes.sort { (r1, r2) -> Bool in
                    return r1.creationDate.compare(r2.creationDate) == .orderedDescending
                }
            case "reviews":
                self.recipes = incomingRecipes.filter { $0.reviewsDictionary != nil }
                self.recipes.sort(by: { (r1, r2) -> Bool in
                    
                    if r1.reviewsDictionary!.count == r2.reviewsDictionary!.count {
                        return r1.creationDate.compare(r2.creationDate) == .orderedDescending
                    } else {
                        return r1.reviewsDictionary!.count > r2.reviewsDictionary!.count
                    }
                })
            case "recipeScore":
                self.recipes.sort {
                    if $0.recipeScore == $1.recipeScore {
                        return $0.creationDate.compare($1.creationDate) == .orderedDescending
                    } else {
                        return $0.recipeScore > $1.recipeScore
                    }
                }
            default:
                print("No sort")
            }
        } else {
            self.recipes.shuffle()
        }
    }
    
    func openMapView() {
        let mapView = RecipesMapView()
        mapView.filteredRecipes = self.searchResultRecipes
        let viewContentEvent = AppEvent.viewedContent(contentType: "interactive-map", contentId: nil, currency: nil, valueToSum: 1.0, extraParameters: ["numberOfRecipes": self.searchResultRecipes.count])
        AppEventsLogger.log(viewContentEvent)
        self.navigationController?.pushViewController(mapView, animated: true)
    }
}

extension HomeVC: UITextFieldDelegate {
    @objc func textChanged(textField: UITextField) {
        if let text = textField.text {
            print(text)
            if text.isEmpty {
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
            
            if recipe.country != nil {
                let countryWords = recipe.country!.lowercased().components(separatedBy: " ")
                let countryMatches = countryWords.filter { $0 == word }.count
                countryCount += countryMatches
            }
            
            if recipe.locality != nil {
                let localityWords = recipe.locality!.lowercased().components(separatedBy: " ")
                let localityMatches = localityWords.filter { $0 == word }.count
                localityCount += localityMatches
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
                self.searchResultRecipes = Array(self.recipes.prefix(25))
            }
    
            self.tableView.reloadSections([1], with: .automatic)
        }
        
        return true
    }
    
    func searchRecipes(text: String) {
        
        let splitText = text.lowercased().components(separatedBy: " ")
        let recipesToSearch = filtersLauncher.filtersApplied ? filteredRecipes : recipes
        
        let matchingRecipes = recipesToSearch.filter { calculateSearchScore(recipe: $0, text: splitText) > 0 }
        
        let successful = matchingRecipes.count > 0
        let searchEvent = AppEvent.searched(contentId: nil, searchedString: text.lowercased(), successful: successful, valueToSum: 1.0, extraParameters: ["numberOfResults": matchingRecipes.count])
        AppEventsLogger.log(searchEvent)
        
        self.filteredRecipes = matchingRecipes.sorted(by: { (r1, r2) -> Bool in
            calculateSearchScore(recipe: r1, text: splitText) > calculateSearchScore(recipe: r2, text: splitText)
        })
        
        self.searchResultRecipes = Array(filteredRecipes.prefix(25))
        
//        self.tableView.reloadSections([1], with: .automatic)
        self.tableView.reloadData()
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
}

extension HomeVC: RecipeCellDelegate {
    func didTapFavorite(for cell: RecipeCell) {
        if let browsing = UserDefaults.standard.value(forKey: "isBrowsing") as? Bool, browsing {
            let accountAccessVC = AccountAccessVC()
            accountAccessVC.needAccount()
            self.present(accountAccessVC, animated: true, completion: nil)
        } else {
            guard let indexPath = tableView?.indexPath(for: cell) else { return }
            
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
                
                self.pointAdder(numberOfPoints: -1, cell: cell)
                self.pointAdderForCurrentUserID(numberOfPoints: -1)
                
                self.searchResultRecipes[indexPath.item] = recipe
                
                self.tableView.reloadRows(at: [indexPath], with: .none)
                
                
                
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
                        
                        self.pointAdder(numberOfPoints: 1, cell: cell)
                        self.pointAdderForCurrentUserID(numberOfPoints: 1)

                        
                        
                        self.searchResultRecipes[indexPath.item] = recipe
                        
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                        
                        NotificationCenter.default.post(name: Notification.Name("FavoritesChanged"), object: nil)
                    }
                }
            }
        }
    }
}

extension HomeVC {
    
    func pointAdder(numberOfPoints: Int, cell: RecipeCell) {
        guard let indexPath = tableView?.indexPath(for: cell) else { return }
        var recipe = self.searchResultRecipes[indexPath.item]
            
        let recipeUID = recipe.uid
            
            FirebaseController.shared.fetchRecipeWithUID(uid: recipeUID) { (recipe) in
                guard let recipe = recipe else { return }
                let cook = recipe.creator
                var points = recipe.creator.points
                let newPoints = points != nil ? points! + numberOfPoints : numberOfPoints
                FirebaseController.shared.ref.child("users").child((cook.uid)).child("points").setValue(newPoints)
            }
        }
    
    func pointAdderForCurrentUserID(numberOfPoints: Int) {
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        FirebaseController.shared.fetchUserWithUID(uid: userID) { (user) in
            guard let user = user else { return }
            var points = user.points
            let newPoints = points != nil ? points! + numberOfPoints : numberOfPoints
            FirebaseController.shared.ref.child("users").child(userID).child("points").setValue(newPoints)
        }
    }
    
    func pointUpToSpeed() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        FirebaseController.shared.fetchUserWithUID(uid: userID) { (user) in
            guard let user = user else { return }
            
            if user.points == 0 || user.points == nil {
                
                //recipesCookedByYou
                //RecipesSavedByYou
                //reviewsLeftByYou
                //recipescookedByOthers
                //recipesfavoritedByOthers
                //reviewsLeftByOthers
                self.recipesCookedByYoursTruly {
                    self.savedRecipes {
                        self.yourReviewedRecipes {
                            self.recipescookedByOthers {
                                self.recipesFavoritedByOthers {
                                    self.theyReviewedRecipes()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
    func recipesCookedByYoursTruly(completion: @escaping () -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        FirebaseController.shared.fetchUserWithUID(uid: userID) { (useR) in
            FirebaseController.shared.ref.child("users").child(userID).child("cookedRecipes").observe(.value) { (snapshot) in
                let totalPoints = Int(snapshot.childrenCount) * 5
                var points = useR?.points
                let newPoints = points != nil ? points! + totalPoints : totalPoints
                FirebaseController.shared.ref.child("users").child((userID)).child("points").setValue(newPoints)
                completion()
            }
        }
    }
    
    func savedRecipes(completion: @escaping () -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        
        FirebaseController.shared.fetchUserWithUID(uid: userID) { (useR) in
            FirebaseController.shared.ref.child("users").child(userID).child("favorites").observe(.value) { (snapshot) in
                let totalPoints = Int(snapshot.childrenCount) * 1
                var points = useR?.points
                let newPoints = points != nil ? points! + totalPoints : totalPoints
                FirebaseController.shared.ref.child("users").child((userID)).child("points").setValue(newPoints)
                completion()
            }
        }
    }
    
    func yourReviewedRecipes(completion: @escaping () -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        FirebaseController.shared.fetchUserWithUID(uid: userID) { (useR) in
            
            FirebaseController.shared.ref.child("users").child(userID).child("reviewRecipes").observe(.value) { (snapshot) in
                let totalPoints = Int(snapshot.childrenCount) * 10
                var points = useR?.points
                let newPoints = points != nil ? points! + totalPoints : totalPoints
                FirebaseController.shared.ref.child("users").child((userID)).child("points").setValue(newPoints)
                completion()
            }
        }
    }
    
    func theyReviewedRecipes() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        FirebaseController.shared.fetchUserWithUID(uid: userID) { (useR) in
            
            FirebaseController.shared.ref.child("users").child(userID).child("uploadedRecipes").observeSingleEvent(of: .value) { (result) in
                for recipe in result.children.allObjects as! [DataSnapshot] {
                    
                    let recipeUID = recipe.key
                    
                    FirebaseController.shared.ref.child("recipes").child(recipeUID).child("reviews").observeSingleEvent(of: .value) { (snapshot) in
                        let totalPoints = Int(snapshot.childrenCount) * 10
                        var points = useR?.points
                        let newPoints = points != nil ? points! + totalPoints : totalPoints
                        FirebaseController.shared.ref.child("users").child((userID)).child("points").setValue(newPoints)
                    }
                }
            }
        }
    }
    
    func recipescookedByOthers(completion: @escaping () -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        FirebaseController.shared.fetchUserWithUID(uid: userID) { (useR) in
            FirebaseController.shared.ref.child("users").child(userID).child("uploadedRecipes").observeSingleEvent(of: .value) { (result) in
                for recipe in result.children.allObjects as! [DataSnapshot] {
                    
                    let recipeUID = recipe.key
                    
                    FirebaseController.shared.ref.child("recipes").child(recipeUID).child("cookedImages").observeSingleEvent(of: .value) { (snapshot) in
                        let totalPoints = Int(snapshot.childrenCount) * 10
                        var points = useR?.points
                        let newPoints = points != nil ? points! + totalPoints : totalPoints
                        FirebaseController.shared.ref.child("users").child((userID)).child("points").setValue(newPoints)
                        completion()
                    }
                }
            }
        }
    }
    
    func recipesFavoritedByOthers(completion: @escaping () -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        FirebaseController.shared.fetchUserWithUID(uid: userID) { (useR) in
            
            FirebaseController.shared.ref.child("users").child(userID).child("uploadedRecipes").observeSingleEvent(of: .value) { (result) in
                for recipe in result.children.allObjects as! [DataSnapshot] {
                    
                    let recipeUID = recipe.key
                    
                    FirebaseController.shared.ref.child("recipes").child(recipeUID).child("favoritedBy").observeSingleEvent(of: .value) { (snapshot) in
                        let totalPoints = Int(snapshot.childrenCount) * 1
                        var points = useR?.points
                        let newPoints = points != nil ? points! + totalPoints : totalPoints
                        FirebaseController.shared.ref.child("users").child((userID)).child("points").setValue(newPoints)
                        completion()
                    }
                }
            }
        }
    }
    
    }


