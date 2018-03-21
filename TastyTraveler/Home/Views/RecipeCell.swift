//
//  RecipeCell.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/15/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia

class RecipeCell: BaseCell {
    
    var recipe: Recipe? {
        didSet {
//            guard let photoURL = recipe?.photoURL else { return }
//            photoImageView.loadImage(urlString: photoURL)
            countryLabel.text = recipe?.country
            if let countryCode = recipe?.countryCode { countryFlag.image = UIImage(named: countryCode) }

            recipeNameLabel.text = recipe?.name
            creatorNameLabel.text = "by \(recipe!.creator.username)"

            if let overallRating = recipe?.overallRating {
                starsImageView.image = starsImageForRating(overallRating.round(nearest: 0.5))
            } else {
                starsImageView.isHidden = true
                numberOfRatingsLabel.text = "No Ratings"
            }

            favoriteButton.setImage(recipe?.hasFavorited == true ? #imageLiteral(resourceName: "favoriteButtonSelected") : #imageLiteral(resourceName: "favoriteButton"), for: .normal)
            
            if let ratings = recipe?.ratings {
                let text = "(\(ratings.count))"
                numberOfRatingsLabel.text = text
            }
        }
    }
    
    let shadowView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = adaptConstant(12)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: adaptConstant(10))
        view.layer.shadowRadius = adaptConstant(25)
        return view
    }()
    
    let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = adaptConstant(12)
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        return view
    }()
    
    let photoImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.image = #imageLiteral(resourceName: "image")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.height(adaptConstant(185))
        return imageView
    }()
    
    let countryFlag: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "PR")
        imageView.height(adaptConstant(15)).width(adaptConstant(22))
        return imageView
    }()
    
    let countryLabel: UILabel = {
        let label = UILabel()
        label.text = "test"
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
    
    let starsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.width(adaptConstant(95)).height(adaptConstant(15))
        return imageView
    }()
    
    let numberOfRatingsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        label.textColor = UIColor(hexString: "999999")
        label.text = "(te)"
        return label
    }()
    
    override func setUpViews() {
        sv(shadowView.sv(containerView.sv(photoImageView,
                             countryFlag,
                             countryLabel,
                             recipeNameLabel,
                             creatorNameLabel,
                             favoriteButton,
                             starsImageView,
                             numberOfRatingsLabel)))
        
        shadowView.fillContainer()
        containerView.fillContainer()
        
        photoImageView.top(0).left(0).right(0)
        
        countryFlag.left(adaptConstant(10))
        countryFlag.Top == photoImageView.Bottom + adaptConstant(12)
        countryLabel.Left == countryFlag.Right + adaptConstant(4)
        countryLabel.CenterY == countryFlag.CenterY
        
        recipeNameLabel.left(adaptConstant(10)).right(adaptConstant(10))
        recipeNameLabel.Top == countryFlag.Bottom
        
        creatorNameLabel.left(adaptConstant(10))
        creatorNameLabel.Top == recipeNameLabel.Bottom
        
        favoriteButton.right(adaptConstant(14))
        favoriteButton.CenterY == photoImageView.Bottom
        
        numberOfRatingsLabel.right(adaptConstant(10))
        starsImageView.CenterY == creatorNameLabel.CenterY
        numberOfRatingsLabel.CenterY == creatorNameLabel.CenterY
        starsImageView.Right == numberOfRatingsLabel.Left - adaptConstant(4)
        
        creatorNameLabel.bottom(adaptConstant(16))
    }
    
    func starsImageForRating(_ rating: Double) -> UIImage {
        switch rating {
        case 0.5:
            return #imageLiteral(resourceName: "starsOneHalf")
        case 1.0:
            return #imageLiteral(resourceName: "starsOne")
        case 1.5:
            return #imageLiteral(resourceName: "starsOneAndHalf")
        case 2.0:
            return #imageLiteral(resourceName: "starsTwo")
        case 2.5:
            return #imageLiteral(resourceName: "starsTwoAndHalf")
        case 3.0:
            return #imageLiteral(resourceName: "starsThree")
        case 3.5:
            return #imageLiteral(resourceName: "starsThreeAndHalf")
        case 4.0:
            return #imageLiteral(resourceName: "starsFour")
        case 4.5:
            return #imageLiteral(resourceName: "starsFourAndHalf")
        case 5.0:
            return #imageLiteral(resourceName: "starsFive")
        default:
            return #imageLiteral(resourceName: "starsZero")
        }
    }
}
