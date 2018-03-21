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
    
    let recipes: [Recipe] = [
        Recipe(creator: User(uid: "jfo3iwfj23fj92", username: "Michael Bart"), dictionary: ["name": "a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a",
                                                                                            "ratings": [1,2,3,4,2,5,4,3,4,5],
                                                                                            "photoURL": "https://pasteboard.co/HcFS7r4.png",
                                                                                            "country": "Puerto Rico",
                                                                                            "countryCode": "PR"]),
        Recipe(creator: User(uid: "jfo3iwfj23fj92", username: "Michael Bart"), dictionary: ["name": "Arroz con pollo",
                                                                                            "photoURL": "https://pasteboard.co/HcFS7r4.png",
                                                                                            "country": "Puerto Rico",
                                                                                            "countryCode": "PR"]),
        
        Recipe(creator: User(uid: "jfo3iwfj23fj92", username: "Michael Bart"), dictionary: ["name": "Arroz con pollo",
                                                                                            "ratings": [1,2,3,4,2,5,4,3,4,5],
                                                                                            "photoURL": "https://pasteboard.co/HcFS7r4.png",
                                                                                            "country": "Puerto Rico",
                                                                                            "countryCode": "PR"]),
        Recipe(creator: User(uid: "jfo3iwfj23fj92", username: "Michael Bart"), dictionary: ["name": "Arroz con pollo",
                                                                                            "ratings": [1,2,3,4,2,5,4,3,4,5],
                                                                                            "photoURL": "https://pasteboard.co/HcFS7r4.png",
                                                                                            "country": "Puerto Rico",
                                                                                            "countryCode": "PR"]),
        Recipe(creator: User(uid: "jfo3iwfj23fj92", username: "Michael Bart"), dictionary: ["name": "Arroz con pollo",
                                                                                            "ratings": [1,2,3,4,2,5,4,3,4,5],
                                                                                            "photoURL": "https://pasteboard.co/HcFS7r4.png",
                                                                                            "country": "Puerto Rico",
                                                                                            "countryCode": "PR"])
    ]

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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return adaptConstant(20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, adaptConstant(18), 0 )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: adaptConstant(125))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let recipe = self.recipes[indexPath.row] as? Recipe {
            let approximateWidthOfRecipeNameLabel = view.frame.width - adaptConstant(18) - adaptConstant(18) - adaptConstant(20)
            let size = CGSize(width: approximateWidthOfRecipeNameLabel, height: 1000)
            let attributes = [NSAttributedStringKey.font: UIFont(name: "ProximaNova-Bold", size: adaptConstant(22))!]
            let estimatedFrame = NSString(string: recipe.name).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)

            return CGSize(width: view.frame.width - adaptConstant(36), height: estimatedFrame.height + adaptConstant(265)) // 270
        }
        
        return CGSize(width: view.frame.width - adaptConstant(36), height: 300)
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
        return recipes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RecipeCell
        
        let recipe = recipes[indexPath.row]
        
        cell.recipe = recipe
        return cell
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
//        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
//
        if notification.name == Notification.Name.UIKeyboardWillHide {
            self.view.removeGestureRecognizer(tapGesture)
            //self.collectionView?.contentInset = UIEdgeInsets.zero
        } else {
            self.view.addGestureRecognizer(tapGesture)
            //self.collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        //self.collectionView?.scrollIndicatorInsets = self.collectionView!.contentInset
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
}

extension HomeVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
}
