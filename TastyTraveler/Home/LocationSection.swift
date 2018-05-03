//
//  LocationSection.swift
//  TastyTraveler
//
//  Created by Michael Bart on 4/20/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia
import Firebase

class LocationSection: BaseCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(hexString: "F8F8FB")
        collectionView.contentInset = UIEdgeInsets(top: adaptConstant(12), left: 0, bottom: 0, right: 0)
        return collectionView
    }()
    
    var filtersLauncher: FiltersLauncher!
    var countries = [String]()
    var countryCodes = [String:String]()
    
    override func setUpViews() {
        super.setUpViews()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(LocationCell.self, forCellWithReuseIdentifier: "locationCell")
        
        sv(collectionView)
        collectionView.fillContainer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(deselectFilter(_:)), name: Notification.Name("RemoveFilterNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeAllFilters), name: Notification.Name("RemoveAllFiltersNotification"), object: nil)
    }
    
    @objc func deselectFilter(_ notification: Notification) {
        if let filterText = notification.userInfo?["filterText"] as? String {
            if let index = countries.index(of: filterText) {
                collectionView.deselectItem(at: IndexPath(item: index, section: 0), animated: true)
            }
        }
    }
    
    @objc func removeAllFilters() {
        let indexPaths = collectionView.indexPathsForSelectedItems
        indexPaths?.forEach({ collectionView.deselectItem(at: $0, animated: false) })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.countries.count < 20 {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height / 6)
        } else {
            return CGSize(width: collectionView.frame.width / 2, height: collectionView.frame.height / 6)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "locationCell", for: indexPath) as! LocationCell
        
        let country = countries[indexPath.item]
        cell.locationLabel.text = country
        
        if let countryCode = countryCodes[country] {
            cell.imageView.image = UIImage(named: countryCode)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! LocationCell
        
        guard let location = cell.locationLabel.text else { return }
        
        filtersLauncher.selectedFilters.append(location)
        filtersLauncher.selectedLocations.append(location)
        let index = IndexPath(item: filtersLauncher.selectedFilters.count - 1, section: 0)
        filtersLauncher.selectedFiltersCollectionView.insertItems(at: [index])
        filtersLauncher.selectedFiltersCollectionView.scrollToItem(at: index, at: .right, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! LocationCell
        
        guard let location = cell.locationLabel.text else { return }
        
        if let locationIndex = filtersLauncher.selectedLocations.index(of: location) {
            filtersLauncher.selectedLocations.remove(at: locationIndex)
        }
        
        if let index = filtersLauncher.selectedFilters.index(of: location) {
            filtersLauncher.selectedFilters.remove(at: index)
            filtersLauncher.selectedFiltersCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    func fetchLocations() {
        FirebaseController.shared.ref.child("locations").observeSingleEvent(of: .value) { (snapshot) in
            guard let locationsDictionary = snapshot.value as? [String:[String:Any]] else { return }
            
            locationsDictionary.forEach({ (key, value) in
                guard let countryCode = value["countryCode"] as? String else { return }
                
                self.countryCodes[key] = countryCode
                self.countries.append(key)
            })
            
            self.countries.sort()
            self.collectionView.reloadData()
        }
    }
}

class LocationCell: BaseCell {
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))
        label.textColor = Color.darkText
        return label
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.height(adaptConstant(15)).width(adaptConstant(22))
        return iv
    }()
    
    override func setUpViews() {
        super.setUpViews()
        
        let stackView = UIStackView(arrangedSubviews: [imageView, locationLabel])
        stackView.axis = .horizontal
        stackView.spacing = adaptConstant(8)
        
        sv(stackView)
        
//        stackView.left(adaptConstant(12))
        stackView.centerInContainer()
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
