//
//  HomeVC.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/14/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia

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
    
    let recipe: [String:Any] = ["name": "Chicken and Rice", "country": "Puerto Rico", "creatorUsername": "Jose Ramirez", "rating": 3.5, "numberOfRatings": 27, "image": UIImageView()]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.register(RecipeCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.register(HomeHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        
        self.navigationController?.navigationBar.isHidden = true
        
        self.view.backgroundColor = .white
        self.collectionView?.backgroundColor = .white
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
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
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RecipeCell
        
        cell.recipe = recipe
        
        
        return cell
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            self.view.removeGestureRecognizer(tapGesture)
            self.collectionView?.contentInset = UIEdgeInsets.zero
        } else {
            self.view.addGestureRecognizer(tapGesture)
            self.collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        self.collectionView?.scrollIndicatorInsets = self.collectionView!.contentInset
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
}

extension HomeVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
}
