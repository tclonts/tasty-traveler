//
//  FilterStatusCell.swift
//  TastyTraveler
//
//  Created by Michael Bart on 4/24/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia

class BasicFilterCell: BaseCell {
    
    let filterLabel = UILabel()
    
    override func setUpViews() {
        super.setUpViews()
        
        sv(filterLabel)
        
        self.contentView.layer.cornerRadius = self.contentView.frame.height / 2
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = Color.gray.cgColor
        self.contentView.layer.masksToBounds = true
        
        filterLabel.left(adaptConstant(12)).centerVertically()
        
    }
}


class FilterStatusCell: UIView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    let filteringLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(14))
        label.textColor = Color.darkText
        label.text = "Filtering by:"
        return label
    }()
    
    let filtersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
//        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = adaptConstant(4)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    var homeHeaderView: HomeHeaderView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    func setUpViews() {
        filtersCollectionView.delegate = self
        filtersCollectionView.dataSource = self
        
        filtersCollectionView.register(BasicFilterCell.self, forCellWithReuseIdentifier: "filterCell")
        
        sv(filteringLabel, filtersCollectionView)
        
        filteringLabel.left(0).centerVertically()
        
        filtersCollectionView.Left == filteringLabel.Right + adaptConstant(8)
        filtersCollectionView.top(0).bottom(0).right(adaptConstant(8))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homeHeaderView.homeVC.filtersLauncher.selectedFilters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterCell", for: indexPath) as! BasicFilterCell
        
        cell.backgroundColor = .clear
        
        let selectedFilterText = homeHeaderView.homeVC.filtersLauncher.selectedFilters[indexPath.item]
        let attributedString = NSAttributedString(string: selectedFilterText, attributes: [NSAttributedStringKey.font: UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(12))!, NSAttributedStringKey.foregroundColor: Color.darkGrayText])
        
        cell.filterLabel.attributedText = attributedString
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let attributedString = NSAttributedString(string: homeHeaderView.homeVC.filtersLauncher.selectedFilters[indexPath.row], attributes: [NSAttributedStringKey.font: UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(12))!, NSAttributedStringKey.foregroundColor: Color.darkGrayText])
        // 24 is equal to the margins
        return CGSize(width: attributedString.size().width + adaptConstant(24), height: adaptConstant(20))
    }
}
