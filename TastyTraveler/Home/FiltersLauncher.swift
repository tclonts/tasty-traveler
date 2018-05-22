//
//  FiltersLauncher.swift
//  TastyTraveler
//
//  Created by Michael Bart on 4/17/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia

enum FilterType {
    case meal
    case location
    case tag
}

struct Filter {
    var type: FilterType
    var value: String
}

class FilterCell: BaseCell {
    
    lazy var removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.width(adaptConstant(20))
        button.backgroundColor = Color.gray
        button.setImage(#imageLiteral(resourceName: "removeWhite"), for: .normal)
        button.addTarget(self, action: #selector(removeFilter), for: .touchUpInside)
        return button
    }()
    
    let filterLabel = UILabel()
    
    weak var delegate: FilterCellDelegate?
    
    override func setUpViews() {
        super.setUpViews()
        
        sv(removeButton, filterLabel)
        
        self.contentView.layer.cornerRadius = self.contentView.frame.height / 2
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = Color.gray.cgColor
        self.contentView.layer.masksToBounds = true
        
        filterLabel.left(adaptConstant(26)).centerVertically()
        
        removeButton.left(0).top(0).bottom(0)
    }
    
    @objc func removeFilter() {
        delegate?.removeFilter(cell: self)
    }
}

protocol FilterCellDelegate: class {
    func removeFilter(cell: FilterCell)
}

class FiltersLauncher: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, FilterCellDelegate {
    
    let blackView = UIView()
    
    let mealSectionID = "mealSectionID"
    let locationSectionID = "locationSectionID"
    let tagsSectionID = "tagsSectionID"
    
    let filterCellID = "filterCell"

    var homeVC: HomeVC?
    
    var filtersApplied = false {
        didSet {
            //filtersApplied ? homeVC.showFilteringView() : homeVC.filt
        }
    }
    
    var selectedMeals = [String]()
    var selectedLocations = [String]()
    var selectedTags = [String]()
    
    var selectedFilters = [String]()
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = adaptConstant(12)
        view.layer.masksToBounds = true
        view.layer.shadowOpacity = 0.16
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        view.layer.shadowRadius = 16
        return view
    }()
    
    let filtersLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(20))
        label.text = "Filters"
        label.textColor = Color.darkText
        return label
    }()
    
    lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear all", for: .normal)
        button.setTitleColor(Color.gray, for: .normal)
        button.addTarget(self, action: #selector(clearFilters), for: .touchUpInside)
        return button
    }()
    
    lazy var menuBar: MenuBar = {
        let menuBar = MenuBar()
        menuBar.delegate = self
        menuBar.tabNames = ["Meal", "Location", "Tags"]
        menuBar.setUpHorizontalBar(onTop: true)
        return menuBar
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        let title = NSAttributedString(string: "Apply", attributes: [NSAttributedStringKey.font: UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(18))!, NSAttributedStringKey.foregroundColor: UIColor.white])
        button.setAttributedTitle(title, for: .normal)
        button.backgroundColor = Color.primaryOrange
        button.addTarget(self, action: #selector(applyFilters), for: .touchUpInside)
        button.layer.cornerRadius = adaptConstant(12)
        button.layer.shadowOpacity = 0.16
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.layer.shadowRadius = 16
        return button
    }()
    
    let selectedFiltersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.contentInset = UIEdgeInsets(top: 0, left: adaptConstant(8), bottom: 0, right: 0)
        return collectionView
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = UIColor(hexString: "F8F8FB")
        collectionView.bounces = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    lazy var swipeDownGesture: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(handleDismiss))
        gesture.direction = .down
        return gesture
    }()
    
    override init() {
        super.init()
        
        selectedFiltersCollectionView.dataSource = self
        selectedFiltersCollectionView.delegate = self
        
        selectedFiltersCollectionView.register(FilterCell.self, forCellWithReuseIdentifier: filterCellID)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(MealSection.self, forCellWithReuseIdentifier: mealSectionID)
        collectionView.register(LocationSection.self, forCellWithReuseIdentifier: locationSectionID)
        collectionView.register(TagsSection.self, forCellWithReuseIdentifier: tagsSectionID)
        
        setUpViews()
        
        containerView.addGestureRecognizer(swipeDownGesture)
    }
    
    func setUpViews() {
        containerView.sv(backgroundView.sv(filtersLabel, clearButton, selectedFiltersCollectionView, collectionView, menuBar), doneButton)
        
        backgroundView.top(0).left(0).right(0)
        
        filtersLabel.top(adaptConstant(8)).centerHorizontally()
        clearButton.right(adaptConstant(27))
        clearButton.CenterY == filtersLabel.CenterY
        selectedFiltersCollectionView.left(0).right(0).height(adaptConstant(45))
        selectedFiltersCollectionView.Top == filtersLabel.Bottom
        collectionView.Top == selectedFiltersCollectionView.Bottom
        collectionView.left(0).right(0)
        collectionView.Bottom == menuBar.Top
        menuBar.height(adaptConstant(50)).left(0).right(0).bottom(0)
        
        doneButton.Top == backgroundView.Bottom + 8
        doneButton.height(adaptConstant(44)).left(0).right(0).bottom(0)
    }
    
    func removeFilter(cell: FilterCell) {
        
        if let index = selectedMeals.index(of: cell.filterLabel.text!) {
            selectedMeals.remove(at: index)
        } else if let index = selectedLocations.index(of: cell.filterLabel.text!) {
            selectedLocations.remove(at: index)
        } else if let index = selectedTags.index(of: cell.filterLabel.text!) {
            selectedTags.remove(at: index)
        }
        
        if let indexPath = selectedFiltersCollectionView.indexPath(for: cell) {
            selectedFilters.remove(at: indexPath.item)
            selectedFiltersCollectionView.deleteItems(at: [indexPath])
            let userInfo = ["filterText": cell.filterLabel.text!]
            //  USE NOTIFICATION USER INFO LATER TO REMOVE FROM SELECTEDMEALS/SELECTEDLOCATIONS/SELECTEDTAGS ARRAY??
            NotificationCenter.default.post(name: Notification.Name("RemoveFilterNotification"), object: nil, userInfo: userInfo)
        } else {
            print("NO INDEX PATH TO REMOVE FILTER")
        }
    }
    
    func showFilters() {
        if let window = UIApplication.shared.keyWindow {
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            window.addSubview(blackView)
            window.addSubview(containerView)
            
            let height: CGFloat = adaptConstant(433)
            let y = window.frame.height - height - window.safeAreaInsets.bottom - 8
            
            
            containerView.frame = CGRect(x: adaptConstant(12), y: window.frame.height, width: window.frame.width - adaptConstant(24), height: height)
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackView.alpha = 1
                self.containerView.frame = CGRect(x: adaptConstant(12), y: y, width: self.containerView.frame.width, height: self.containerView.frame.height)
            }, completion: nil)
        }
    }
    
    @objc func applyFilters() {
        // recipes with selected meals, selected countries, selected tags
        // TODO: Make more efficient by querying the firebase database directly
//        if !selectedMeals.isEmpty { FirebaseController.shared.filterRecipesByMeal(types: [selectedMeals]) }
//        if !selectedLocations.isEmpty { FirebaseController.shared.filterRecipesByLocation(locations: [selectedLocations]) }
        guard homeVC != nil else { return }
        guard !selectedFilters.isEmpty else { handleDismiss(); filtersApplied = false; homeVC?.handleRefresh(); return }
        
        if !selectedMeals.isEmpty {
            homeVC?.searchResultRecipes = homeVC!.searchResultRecipes.filter { selectedMeals.contains($0.meal!) }
        }
        
        if !selectedLocations.isEmpty {
            homeVC?.searchResultRecipes = homeVC!.searchResultRecipes.filter { recipe in
                guard let country = recipe.country else { return false }
                return selectedLocations.contains(country)
            }
        }
        
        if !selectedTags.isEmpty {
            homeVC?.searchResultRecipes = homeVC!.searchResultRecipes.filter { recipe in
                guard let recipeTags = recipe.tags else { return false }
                let selectedTagsSet = Set(selectedTags)
                let tagsArray = recipeTags.map { $0.rawValue }
                let recipeTagsSet = Set(tagsArray)
                
                return !selectedTagsSet.isDisjoint(with: recipeTagsSet)
            }
        }
        
        filtersApplied = true
        handleDismiss()
        homeVC?.collectionView?.reloadData()
        if homeVC!.searchResultRecipes.isEmpty {
            homeVC?.showEmptyView()
        } else {
            homeVC?.hideEmptyView()
//            homeVC?.filterStatusView.isHidden = false
//            homeVC?.filterStatusView.filtersCollectionView.reloadData()
        }
    }
    
    @objc func clearFilters() {
        self.selectedFilters = []
        self.selectedMeals = []
        self.selectedTags = []
        self.selectedLocations = []
        self.selectedFiltersCollectionView.reloadData()
        //self.filtersApplied = false
        NotificationCenter.default.post(name: Notification.Name("RemoveAllFiltersNotification"), object: nil)
    }
    
    @objc func handleDismiss() {
        if !filtersApplied {
            clearFilters()
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackView.alpha = 0
            
            if let window = UIApplication.shared.keyWindow {
                self.containerView.frame = CGRect(x: adaptConstant(12), y: window.frame.height, width: self.containerView.frame.width, height: self.containerView.frame.height)
            }
        }) { (completed) in
            
        }
    }
    
//    @objc func dismissView(gesture: UISwipeGestureRecognizer) {
//        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//            self.blackView.alpha = 0
//
//            if let window = UIApplication.shared.keyWindow {
//                gesture.view?.frame = CGRect(x: 0, y: window.frame.height, width: self.backgroundView.frame.width, height: self.backgroundView.frame.height)
//            }
//        }) { (completed) in
//
//        }
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == selectedFiltersCollectionView {
            return selectedFilters.count
        } else {
            return menuBar.tabNames.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == selectedFiltersCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterCellID, for: indexPath) as! FilterCell
            
            let selectedFilterText = selectedFilters[indexPath.item]
            let attributedString = NSAttributedString(string: selectedFilterText, attributes: [NSAttributedStringKey.font: UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(12))!, NSAttributedStringKey.foregroundColor: Color.darkGrayText])
            
            cell.filterLabel.attributedText = attributedString
            cell.delegate = self
            
            return cell
        }
        
        if collectionView == self.collectionView {
            switch indexPath.item {
            case 0:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: mealSectionID, for: indexPath) as! MealSection
                cell.filtersLauncher = self
                return cell
            case 1:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: locationSectionID, for: indexPath) as! LocationSection
                cell.filtersLauncher = self
                cell.fetchLocations()
                return cell
            case 2:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tagsSectionID, for: indexPath) as! TagsSection
                cell.filtersLauncher = self
                return cell
            default:
                print("No")
            }
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == selectedFiltersCollectionView {
            let attributedString = NSAttributedString(string: selectedFilters[indexPath.row], attributes: [NSAttributedStringKey.font: UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(12))!, NSAttributedStringKey.foregroundColor: Color.darkGrayText])
            return CGSize(width: attributedString.size().width + adaptConstant(20) + adaptConstant(18), height: adaptConstant(20))
        } else {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            menuBar.horizontalBarLeftConstraint?.constant = scrollView.contentOffset.x / 3
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == collectionView {
            let index = targetContentOffset.pointee.x / collectionView.frame.width
            let indexPath = IndexPath(item: Int(index.rounded()), section: 0)
            menuBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition())
        }
    }
}

extension FiltersLauncher: MenuBarDelegate {
    func scrollToMenuIndex(_ menuIndex: Int) {
        let indexPath = IndexPath(item: menuIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: true)
    }
}
