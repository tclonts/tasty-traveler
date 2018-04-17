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
            guard let photoURL = recipe?.photoURL else { return }
            recipeHeaderView.photoImageView.loadImage(urlString: photoURL)
            recipeHeaderView.countryLabel.text = "United States"//recipe?.country
            if let countryCode = recipe?.countryCode { recipeHeaderView.countryFlag.image = UIImage(named: countryCode) }

            recipeHeaderView.recipeNameLabel.text = recipe?.name
            recipeHeaderView.creatorNameLabel.text = "by \(recipe!.creator.username)"

            if let overallRating = recipe?.overallRating {
                recipeHeaderView.starsImageView.image = starsImageForRating(overallRating.round(nearest: 0.5))
            } else {
                recipeHeaderView.starsImageView.isHidden = true
                recipeHeaderView.numberOfRatingsLabel.text = "No Ratings"
            }

            recipeHeaderView.favoriteButton.setImage(recipe?.hasFavorited == true ? #imageLiteral(resourceName: "favoriteButtonSelected") : #imageLiteral(resourceName: "favoriteButton"), for: .normal)
            
            if let ratings = recipe?.ratings {
                let text = "(\(ratings.count))"
                recipeHeaderView.numberOfRatingsLabel.text = text
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
    
    let recipeHeaderView = RecipeHeaderView()
    
    override func setUpViews() {
        sv(shadowView.sv(recipeHeaderView))
        
        shadowView.fillContainer()
        recipeHeaderView.fillContainer()
        recipeHeaderView.layer.cornerRadius = adaptConstant(12)
        recipeHeaderView.clipsToBounds = true
        recipeHeaderView.layer.masksToBounds = true
        
        recipeHeaderView.photoImageView.top(0).left(0).right(0)
        recipeHeaderView.photoImageView.Height == recipeHeaderView.photoImageView.Width * 0.75
        
        recipeHeaderView.countryFlag.left(adaptConstant(10))
        recipeHeaderView.countryFlag.Top == recipeHeaderView.photoImageView.Bottom + adaptConstant(12)
        recipeHeaderView.countryLabel.Left == recipeHeaderView.countryFlag.Right + adaptConstant(4)
        recipeHeaderView.countryLabel.CenterY == recipeHeaderView.countryFlag.CenterY
        
        recipeHeaderView.recipeNameLabel.left(adaptConstant(10)).right(adaptConstant(10))
        recipeHeaderView.recipeNameLabel.Top == recipeHeaderView.countryFlag.Bottom
        
        recipeHeaderView.creatorNameLabel.left(adaptConstant(10))
        recipeHeaderView.creatorNameLabel.Top == recipeHeaderView.recipeNameLabel.Bottom
        
        recipeHeaderView.favoriteButton.right(adaptConstant(14))
        recipeHeaderView.favoriteButton.CenterY == recipeHeaderView.photoImageView.Bottom
        
        recipeHeaderView.numberOfRatingsLabel.right(adaptConstant(10))
        recipeHeaderView.starsImageView.CenterY == recipeHeaderView.creatorNameLabel.CenterY
        recipeHeaderView.numberOfRatingsLabel.CenterY == recipeHeaderView.creatorNameLabel.CenterY
        recipeHeaderView.starsImageView.Right == recipeHeaderView.numberOfRatingsLabel.Left - adaptConstant(4)
        
        recipeHeaderView.creatorNameLabel.bottom(adaptConstant(16))
    }
    
    override func prepareForReuse() {
        recipeHeaderView.heroID = ""
    }
    
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
