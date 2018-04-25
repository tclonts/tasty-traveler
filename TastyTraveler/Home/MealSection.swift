//
//  MealSection.swift
//  TastyTraveler
//
//  Created by Michael Bart on 4/20/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia

class MealSection: BaseCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(hexString: "F8F8FB")
        return collectionView
    }()
    
    var meals = ["Breakfast", "Lunch", "Dinner", "Snack", "Dessert", "Drink"]
    
    var filtersLauncher: FiltersLauncher!
    
    override func setUpViews() {
        super.setUpViews()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(MealCell.self, forCellWithReuseIdentifier: "mealCell")
        
        sv(collectionView)
        collectionView.fillContainer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(deselectFilter(_:)), name: Notification.Name("RemoveFilterNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeAllFilters), name: Notification.Name("RemoveAllFiltersNotification"), object: nil)
    }
    
    @objc func deselectFilter(_ notification: Notification) {
        if let filterText = notification.userInfo?["filterText"] as? String {
            if let index = meals.index(of: filterText) {
                collectionView.deselectItem(at: IndexPath(item: index, section: 0), animated: true)
            }
        }
    }
    
    @objc func removeAllFilters() {
        let indexPaths = collectionView.indexPathsForSelectedItems
        indexPaths?.forEach({ collectionView.deselectItem(at: $0, animated: false) })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return meals.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3, height: collectionView.frame.height / 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mealCell", for: indexPath) as! MealCell
        
        cell.label.text = meals[indexPath.item]
        cell.imageView.image = UIImage(named: meals[indexPath.item])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MealCell
        
        guard let meal = cell.label.text else { return }
        
        filtersLauncher.selectedFilters.append(meal)
        filtersLauncher.selectedMeals.append(meal)
        let index = IndexPath(item: filtersLauncher.selectedFilters.count - 1, section: 0)
        filtersLauncher.selectedFiltersCollectionView.insertItems(at: [index])
        filtersLauncher.selectedFiltersCollectionView.scrollToItem(at: index, at: .right, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MealCell
        
        guard let meal = cell.label.text else { return }
        
        if let mealIndex = filtersLauncher.selectedMeals.index(of: meal) {
            filtersLauncher.selectedMeals.remove(at: mealIndex)
        }
        
        if let index = filtersLauncher.selectedFilters.index(of: meal) {
            filtersLauncher.selectedFilters.remove(at: index)
            filtersLauncher.selectedFiltersCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        }
    }
}

class MealCell: BaseCell {
    
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(18))
        label.textColor = Color.darkText
        return label
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.width(adaptConstant(60)).height(adaptConstant(60))
        return iv
    }()
    
    override func setUpViews() {
        super.setUpViews()
        
        let stackView = UIStackView(arrangedSubviews: [imageView, label])
        stackView.axis = .vertical
        stackView.spacing = adaptConstant(8)
        stackView.alignment = .center
        
        sv(stackView)
        stackView.centerInContainer()
        
        //backgroundColor = .clear
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.alpha = 0.3
            } else {
                self.alpha = 1.0
            }
        }
    }
}
