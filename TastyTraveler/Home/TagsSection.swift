//
//  TagsSection.swift
//  TastyTraveler
//
//  Created by Michael Bart on 4/20/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit

class TagsSection: BaseCell, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = adaptConstant(8)
        layout.minimumLineSpacing = adaptConstant(8)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(hexString: "F8F8FB")
        collectionView.contentInset = UIEdgeInsets(top: adaptConstant(20), left: adaptConstant(20), bottom: 0, right: adaptConstant(20))
        return collectionView
    }()
    
    var filtersLauncher: FiltersLauncher!
    
    var tags = ["Vegan",
                "Gluten-free",
                "Vegetarian",
                "Whole 30",
                "Dairy-free",
                "Paleo",
                "Organic"]
    
    override func setUpViews() {
        super.setUpViews()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(TagCell.self, forCellWithReuseIdentifier: "tagCell")
        
        sv(collectionView)
        collectionView.fillContainer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(deselectFilter(_:)), name: Notification.Name("RemoveFilterNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeAllFilters), name: Notification.Name("RemoveAllFiltersNotification"), object: nil)
    }
    
    @objc func deselectFilter(_ notification: Notification) {
        if let filterText = notification.userInfo?["filterText"] as? String {
            if let index = tags.index(of: filterText) {
                collectionView.deselectItem(at: IndexPath(item: index, section: 0), animated: true)
            }
        }
    }
    
    @objc func removeAllFilters() {
        let indexPaths = collectionView.indexPathsForSelectedItems
        indexPaths?.forEach({ collectionView.deselectItem(at: $0, animated: false) })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
//        let attributedString = NSAttributedString(string: tags[indexPath.row], attributes: [NSAttributedStringKey.font: UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(16))!, NSAttributedStringKey.foregroundColor: Color.lightGray])
        return CGSize(width: (collectionView.frame.width / 3) - adaptConstant(20), height: adaptConstant(27))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as! TagCell
        
        let tag = tags[indexPath.item]
        
        let attributedString = NSAttributedString(string: tag, attributes: [NSAttributedStringKey.font: UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(16))!, NSAttributedStringKey.foregroundColor: Color.lightGray])
        
        cell.tagLabel.attributedText = attributedString
        cell.backgroundColor = .clear
        cell.unselectedBackgroundView.backgroundColor = .clear
        cell.setUpViews()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TagCell
        
        guard let tag = cell.tagLabel.text else { return }
        
        filtersLauncher.selectedFilters.append(tag)
        filtersLauncher.selectedTags.append(tag)
        let index = IndexPath(item: filtersLauncher.selectedFilters.count - 1, section: 0)
        filtersLauncher.selectedFiltersCollectionView.insertItems(at: [index])
        filtersLauncher.selectedFiltersCollectionView.scrollToItem(at: index, at: .right, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TagCell
        
        guard let tag = cell.tagLabel.text else { return }
        
        if let tagIndex = filtersLauncher.selectedTags.index(of: tag) {
            filtersLauncher.selectedTags.remove(at: tagIndex)
        }
        
        if let index = filtersLauncher.selectedFilters.index(of: tag) {
            filtersLauncher.selectedFilters.remove(at: index)
            filtersLauncher.selectedFiltersCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        }
    }
}

class FilterTagCell: BaseCell {
    
    override func setUpViews() {
        super.setUpViews()
    }
}
