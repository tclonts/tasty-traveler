//
//  IngredientsCell.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/29/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia

class IngredientsCell: BaseCell, UITableViewDelegate, UITableViewDataSource {
    
    let ingredientsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: "ProximaNova-Bold", size: adaptConstant(20))
        label.textColor = Color.darkText
        label.text = "Ingredients"
        return label
    }()
    
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none
        tv.isScrollEnabled = false
        tv.estimatedRowHeight = adaptConstant(40)
        tv.rowHeight = UITableViewAutomaticDimension
        tv.allowsMultipleSelection = true
        tv.register(IngredientCell.self, forCellReuseIdentifier: "ingredientCell")
        return tv
    }()
    
    var ingredients = [String]()
    
    var delegate: AboutCellDelegate?

    override func setUpViews() {
        super.setUpViews()
        
        sv(ingredientsLabel, tableView)
        
        ingredientsLabel.top(adaptConstant(27)).left(adaptConstant(25))
        
        tableView.left(adaptConstant(25)).right(adaptConstant(25)).bottom(0)
        tableView.Top == ingredientsLabel.Bottom + adaptConstant(18)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ingredientCell") as? IngredientCell else { return UITableViewCell()}
        
        cell.label.text = ingredients[indexPath.row]
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        delegate?.resizeCollectionView(forHeight: self.tableView.contentSize.height, cell: self)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! IngredientCell
        
        let attributes: [NSAttributedStringKey: Any] =
            [NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
             NSAttributedStringKey.foregroundColor : Color.lightGray,
             NSAttributedStringKey.strikethroughStyle: 1]
        
        let text = cell.label.text!
        cell.label.attributedText = NSAttributedString(string: text, attributes: attributes)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("deselect ")
        let cell = tableView.cellForRow(at: indexPath) as! IngredientCell
        
        let attributes: [NSAttributedStringKey: Any] =
            [NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
             NSAttributedStringKey.foregroundColor : Color.darkGrayText,
             NSAttributedStringKey.strikethroughStyle: 0]
        
        let text = cell.label.text!
        cell.label.attributedText = NSAttributedString(string: text, attributes: attributes)
    }
    var isInTableView = false
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView == self.tableView {
//        }
        print("SCROLL TABLE: \(tableView.contentOffset.y)")
        if tableView.contentOffset.y < 0 { isInTableView = true }
        
        if isInTableView {
            scrollView.isScrollEnabled = true
            isInTableView = false
        } else {
            scrollView.isScrollEnabled = tableView.contentOffset.y > 0
        }
    }
}

class IngredientCell: UITableViewCell {
    
    let label = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        label.font = UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))
        label.numberOfLines = 0
        label.textColor = Color.darkGrayText
        
        sv(label)
        
        label.top(adaptConstant(8)).bottom(adaptConstant(8)).left(0).right(0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

