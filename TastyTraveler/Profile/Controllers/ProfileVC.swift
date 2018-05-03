//
//  ProfileVC.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/14/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Firebase

private let favoritesSection = "favoritesSectionCell"
private let cookedSection = "cookedSectionCell"
private let uploadedSection = "uploadedSectionCell"
private let sectionHeaderID = "sectionHeader"

class ProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var sections = ["Favorites", "Cooked", "Uploaded"]
    
    var favoriteRecipes = [Recipe]()
    var cookedRecipes   = [Recipe]()
    var uploadedRecipes = [Recipe]()
    
    var isMyProfile = true

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.register(FavoritesSection.self, forCellWithReuseIdentifier: favoritesSection)
        self.collectionView?.register(CookedSection.self, forCellWithReuseIdentifier: cookedSection)
        self.collectionView?.register(UploadedSection.self, forCellWithReuseIdentifier: uploadedSection)
        self.collectionView?.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: sectionHeaderID)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if isMyProfile {
            return 2
        } else {
            return sections.count
        }
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = isMyProfile ? collectionView.dequeueReusableCell(withReuseIdentifier: cookedSection, for: indexPath) as! CookedSection : collectionView.dequeueReusableCell(withReuseIdentifier: favoritesSection, for: indexPath) as! FavoritesSection
            return cell
        case 1:
            let cell = isMyProfile ? collectionView.dequeueReusableCell(withReuseIdentifier: uploadedSection, for: indexPath) as! UploadedSection : collectionView.dequeueReusableCell(withReuseIdentifier: cookedSection, for: indexPath) as! CookedSection
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: uploadedSection, for: indexPath) as! UploadedSection
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: sectionHeaderID, for: indexPath) as! SectionHeaderView
        
        switch indexPath.section {
        case 0:
            sectionHeaderView.sectionLabel.text = isMyProfile ? sections[1] : sections[0]
            sectionHeaderView.numberOfRecipesLabel.text = isMyProfile ? "\(cookedRecipes.count)" : "\(favoriteRecipes.count)"
        case 1:
            sectionHeaderView.sectionLabel.text = isMyProfile ? sections[2] : sections[1]
            sectionHeaderView.numberOfRecipesLabel.text = isMyProfile ? "\(uploadedRecipes.count)" : "\(cookedRecipes.count)"
        case 2:
            sectionHeaderView.sectionLabel.text = sections[2]
            sectionHeaderView.numberOfRecipesLabel.text = "\(uploadedRecipes.count)"
        default:
            print("Error when setting up view for section header")
        }
        
        return sectionHeaderView
    }

}
