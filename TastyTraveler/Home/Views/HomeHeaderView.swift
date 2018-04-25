//
//  HomeHeaderView.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/15/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia

class CustomSearchField: UITextField {
    
    var homeHeaderView: HomeHeaderView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
}

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
        button.addTarget(self, action: #selector(showFilters), for: .touchUpInside)
        return button
    }()
    
    lazy var searchField: CustomSearchField = {
        let textField = CustomSearchField()
        textField.placeholder = "Search recipes"
        textField.borderStyle = .none
        textField.font = UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(14))
        textField.textColor = Color.darkText
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = false
        textField.layer.shadowRadius = adaptConstant(30)
        textField.layer.shadowOffset = CGSize(width: 0, height: 0)
        textField.layer.shadowOpacity = 0.1
        textField.height(adaptConstant(38))
        
        textField.setLeftPadding(amount: adaptConstant(14))
        textField.setRightPadding(amount: adaptConstant(14))
        
        textField.backgroundColor = .white
        textField.homeHeaderView = self
        return textField
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(cancelSearch), for: .touchUpInside)
        button.isHidden = true
        button.alpha = 0
        return button
    }()
    
    lazy var filterStatusView: FilterStatusCell = {
        let view = FilterStatusCell()
        view.isHidden = true
        view.homeHeaderView = self
        return view
    }()
    
    weak var homeVC: HomeVC!
    weak var searchVC: SearchVC?
    
    override func setUpViews() {
        sv(recipesLabel,
           mapButton,
           filterButton,
           searchField,
           cancelButton,
           filterStatusView)
        
        recipesLabel.left(adaptConstant(18)).top(adaptConstant(16))
        mapButton.right(adaptConstant(18))
        alignCenter(mapButton, with: recipesLabel)
        filterButton.left(adaptConstant(18))
        filterButton.Top == recipesLabel.Bottom + adaptConstant(18)
        searchField.Left == filterButton.Right + adaptConstant(18)
        searchField.right(adaptConstant(18))
        alignCenter(searchField, with: filterButton)
        
        cancelButton.right(adaptConstant(32))
        cancelButton.CenterY == searchField.CenterY
        
        filterStatusView.Top == searchField.Bottom + adaptConstant(18)
        filterStatusView.left(adaptConstant(18)).right(0).height(adaptConstant(30))
    }
    
    @objc func cancelSearch() {
        //homeVC.cancelledSearch = true
        searchVC?.view.removeFromSuperview()
        searchVC?.removeFromParentViewController()
//        UIView.animate(withDuration: 0.3, animations: {
//            self.cancelButton.alpha = 0
//        }) { (completed) in
//            self.cancelButton.isHidden = true
//        }
        //homeVC.view.endEditing(true)
        //searchField.text = ""
        //searchField.resignFirstResponder()
    }
    
    @objc func showFilters() {
        homeVC.showFilters()
    }
}
