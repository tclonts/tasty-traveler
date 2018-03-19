//
//  RecipeCell.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/15/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit

class RecipeCell: BaseCell {
    
    var recipe: [String:Any]? {
        didSet {
            countryLabel.text = recipe?["country"] as? String
            
        }
    }
    
    let photoImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let countryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(12))
        label.textColor = Color.darkGrayText
        return label
    }()
    
    override func setUpViews() {
        
    }
}
