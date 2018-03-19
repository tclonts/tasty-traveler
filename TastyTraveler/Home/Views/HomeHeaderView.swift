//
//  HomeHeaderView.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/15/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia

class HomeHeaderView: BaseCell {
    
    let recipesLabel: UILabel = {
        let label = UILabel()
        label.text = "Recipes"
        label.font = UIFont(name: "ProximaNova-Bold", size: adaptConstant(27))
        label.textColor = Color.blackText
        return label
    }()
    
    lazy var mapButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "mapIcon"), for: .normal)
        button.width(adaptConstant(27)).height(adaptConstant(27))
        return button
    }()
    
    lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "filter"), for: .normal)
        button.width(adaptConstant(27)).height(adaptConstant(31))
        return button
    }()
    
    lazy var searchField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search recipes"
        textField.borderStyle = .none
        textField.font = UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(14))
        textField.textColor = Color.darkText
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = false
        textField.layer.shadowRadius = 30
        textField.layer.shadowOffset = CGSize(width: 0, height: 0)
        textField.layer.shadowOpacity = 0.1
        textField.height(adaptConstant(38))
        
        textField.setLeftPadding(amount: adaptConstant(14))
        textField.setRightPadding(amount: adaptConstant(14))
        
        textField.backgroundColor = .white
        return textField
    }()
    
//    weak var homeVC: HomeVC!
    
    override func setUpViews() {
        sv(recipesLabel,
           mapButton,
           filterButton,
           searchField)
        
        recipesLabel.left(adaptConstant(18)).top(adaptConstant(16))
        mapButton.right(adaptConstant(18))
        alignCenter(mapButton, with: recipesLabel)
        filterButton.left(adaptConstant(18))
        filterButton.Top == recipesLabel.Bottom + adaptConstant(18)
        searchField.Left == filterButton.Right + adaptConstant(18)
        searchField.right(20)
        alignCenter(searchField, with: filterButton)
    }
}
