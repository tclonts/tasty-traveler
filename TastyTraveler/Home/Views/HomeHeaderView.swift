//
//  HomeHeaderView.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/15/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia

class HomeHeaderView: UITableViewCell {
    
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
        button.addTarget(self, action: #selector(openMapView), for: .touchUpInside)
        return button
    }()
    
    lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "filter"), for: .normal)
        button.width(adaptConstant(27)).height(adaptConstant(31))
        button.addTarget(self, action: #selector(showFilters), for: .touchUpInside)
        return button
    }()
    
    lazy var sortButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "sortButton"), for: .normal)
        button.width(adaptConstant(29)).height(adaptConstant(19))
        button.addTarget(self, action: #selector(showSort), for: .touchUpInside)
        return button
    }()

    var searchField: UITextField!
    
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
        view.homeHeaderView = self
        view.isHidden = true
        return view
    }()
    
    let searchStackView = UIStackView()
    let filterSearchStackView = UIStackView()
    
    weak var homeVC: HomeVC!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews() {
        
        searchStackView.addArrangedSubview(filterButton)
        searchStackView.addArrangedSubview(searchField)
        searchStackView.addArrangedSubview(sortButton)
        searchStackView.axis = .horizontal
        searchStackView.spacing = adaptConstant(18)
        searchStackView.alignment = .center
        
        filterStatusView.height(adaptConstant(30))
        
        filterSearchStackView.addArrangedSubview(searchStackView)
        filterSearchStackView.addArrangedSubview(filterStatusView)
        filterSearchStackView.axis = .vertical
        filterSearchStackView.spacing = adaptConstant(18)
        
        sv(recipesLabel,
           mapButton,
           filterSearchStackView)
        
        recipesLabel.left(adaptConstant(18)).top(adaptConstant(16))
        mapButton.right(adaptConstant(18))
        alignCenter(mapButton, with: recipesLabel)
        
        filterSearchStackView.left(adaptConstant(18)).right(adaptConstant(18))
        filterSearchStackView.Top == recipesLabel.Bottom + adaptConstant(18)
        filterSearchStackView.bottom(adaptConstant(18))
        
        sv(cancelButton)
        cancelButton.Right == searchField.Right - adaptConstant(12)
        cancelButton.CenterY == searchField.CenterY
    }
    
    override func prepareForReuse() {
        searchField.text = homeVC.lastSearchText
    }
    
    @objc func cancelSearch() {
        homeVC.cancelledSearch = true
    }
    
    @objc func showFilters() {
        homeVC.showFilters()
    }
    
    @objc func showSort() {
        homeVC.showSort()
    }
    
    @objc func openMapView() {
        homeVC.openMapView()
    }
}
