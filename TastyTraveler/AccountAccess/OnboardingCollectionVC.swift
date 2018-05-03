//
//  OnboardingCollectionVC.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/7/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia

private let reuseIdentifier = "onboardingCell"

class OnboardingCollectionVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var accountAccessVC: AccountAccessVC!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView?.isPagingEnabled = true
        self.collectionView?.showsHorizontalScrollIndicator = false
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 3
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
        let earthImageView = UIImageView(image: #imageLiteral(resourceName: "earth"))
        earthImageView.height(adaptConstant(183)).width(adaptConstant(183))
        
        let circleImageView = UIImageView(image: #imageLiteral(resourceName: "circle"))
        circleImageView.height(adaptConstant(217)).width(adaptConstant(217))
        
        let magnifyingGlassImageView = UIImageView(image: #imageLiteral(resourceName: "magnifyingGlass"))
        magnifyingGlassImageView.height(adaptConstant(119)).width(adaptConstant(121))
        
        let label = UILabel()
        label.text = "Discover authentic recipes from around the world."
        label.font = UIFont(name: "ProximaNova-Regular", size: adaptConstant(20))
        label.alpha = 0.85
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        
        cell.sv(earthImageView, circleImageView, magnifyingGlassImageView, label)
        
        earthImageView.top(adaptConstant(18))
        earthImageView.centerHorizontally()
        
        circleImageView.top(0)
        circleImageView.centerHorizontally()
        
        magnifyingGlassImageView.Bottom == earthImageView.Bottom
        magnifyingGlassImageView.Left == circleImageView.CenterX
        
        label.Top == circleImageView.Bottom + adaptConstant(40)
        label.left(adaptConstant(60)).right(adaptConstant(60))
        label.centerHorizontally()
        
        return cell
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        accountAccessVC.pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        accountAccessVC.pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.view.frame.height)
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
