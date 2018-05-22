//
//  RecipeHeaderView.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/28/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Cosmos

class RecipeHeaderView: UIView {
    
    let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "imagePlaceholder")
        imageView.contentMode = .scaleAspectFit
        imageView.width(adaptConstant(90))
        return imageView
    }()
    
    let photoImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.02)
        return imageView
    }()
    
    let mealLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = Color.primaryOrange
        label.layer.cornerRadius = adaptConstant(10)
        label.clipsToBounds = true
        label.layer.masksToBounds = true
        label.font = UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(12))
        label.textColor = .white
        label.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        return label
    }()
    
    let countryFlag: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "US")
        imageView.height(adaptConstant(15)).width(adaptConstant(22))
        return imageView
    }()
    
    let countryLabel: UILabel = {
        let label = UILabel()
        label.text = "United States"
        label.font = UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(12))
        label.textColor = Color.darkGrayText
        return label
    }()
    
    // 70 character limit
    let recipeNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "ProximaNova-Bold", size: adaptConstant(22))
        label.textColor = Color.darkText
        label.numberOfLines = 0
        return label
    }()
    
    let creatorNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(14))
        label.textColor = Color.darkGrayText
        return label
    }()
    
    lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "favoriteButton"), for: .normal)
        button.layer.shadowOpacity = 0.16
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = adaptConstant(13)
        button.width(adaptConstant(40)).height(adaptConstant(40))
        
        //        button.layer.masksToBounds = true
        return button
    }()
    
    let starRating: CosmosView = {
        let cosmosView = CosmosView()
        cosmosView.settings.updateOnTouch = false
        cosmosView.settings.fillMode = .precise
        cosmosView.settings.starSize = Double(adaptConstant(15))
        cosmosView.settings.starMargin = Double(adaptConstant(4))
        cosmosView.settings.filledColor = Color.primaryOrange
        cosmosView.settings.emptyBorderColor = Color.primaryOrange
        cosmosView.settings.filledBorderColor = Color.primaryOrange
        cosmosView.rating = 0
        cosmosView.text = "(0)"
        cosmosView.settings.textFont = ProximaNova.regular.of(size: 11)
        return cosmosView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        sv(placeholderImageView,
           photoImageView,
           mealLabel,
           countryFlag,
           countryLabel,
           recipeNameLabel,
           creatorNameLabel,
           favoriteButton,
           starRating)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
