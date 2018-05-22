//
//  RatingsView.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/7/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia
import Cosmos
import FirebaseAuth

class RatingsView: UIView {
    
    let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.bold.of(size: 54)
        label.textColor = Color.darkText
        label.textAlignment = .center
        label.text = "0"
        return label
    }()
    
    let outOfFiveLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.bold.of(size: 14)
        label.textColor = Color.gray
        label.textAlignment = .center
        label.text = "out of 5"
        return label
    }()
    
    let tapToRateLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.regular.of(size: 16)
        label.textColor = Color.darkGrayText
        label.text = "Tap to rate:"
        return label
    }()
    
    let starsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "starsGroup")
        imageView.width(39).height(44)
        return imageView
    }()
    
    let fiveStarBar = RatingBar()
    let fourStarBar = RatingBar()
    let threeStarBar = RatingBar()
    let twoStarBar = RatingBar()
    let oneStarBar = RatingBar()
    
    let numberOfRatingsLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.regular.of(size: 14)
        label.textColor = Color.gray
        label.text = "0 Ratings"
        return label
    }()
    
    let ratingControl: CosmosView = {
        let cosmosView = CosmosView()
        cosmosView.settings.updateOnTouch = true
        cosmosView.settings.fillMode = .full
        cosmosView.settings.starSize = Double(adaptConstant(32))
        cosmosView.settings.starMargin = Double(adaptConstant(10))
        cosmosView.settings.filledColor = Color.primaryOrange
        cosmosView.settings.emptyBorderColor = Color.primaryOrange
        cosmosView.settings.filledBorderColor = Color.primaryOrange
        cosmosView.settings.textFont = ProximaNova.regular.of(size: 11)
        return cosmosView
    }()
    
    let errorText: UILabel = {
        let label = UILabel()
        label.text = "Cook this recipe to submit a rating."
        label.font = ProximaNova.regular.of(size: 12)
        label.textAlignment = .center
        label.textColor = Color.lightGray
        label.isHidden = true
        return label
    }()
    
    var aboutCell: AboutCell?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(hexString: "F8F8FB")
        
        let ratingLabelStackView = UIStackView(arrangedSubviews: [ratingLabel, outOfFiveLabel])
        ratingLabelStackView.axis = .vertical
        ratingLabelStackView.spacing = -adaptConstant(8)
        
        // 39
        let ratingBarStackView = UIStackView(arrangedSubviews: [fiveStarBar, fourStarBar, threeStarBar, twoStarBar, oneStarBar])
        ratingBarStackView.height(40).width(adaptConstant(170))
        ratingBarStackView.spacing = 6
        ratingBarStackView.axis = .vertical
        ratingBarStackView.distribution = .fillEqually
        
        sv(ratingLabelStackView, starsImageView, ratingBarStackView, errorText, tapToRateLabel, numberOfRatingsLabel, ratingControl)
        
        ratingLabelStackView.top(adaptConstant(12)).left(adaptConstant(25))
        ratingBarStackView.right(adaptConstant(20)).top(adaptConstant(24))
        
        starsImageView.Right == ratingBarStackView.Left - adaptConstant(12)
        starsImageView.CenterY == ratingBarStackView.CenterY
        
        numberOfRatingsLabel.Top == ratingBarStackView.Bottom + 6
        numberOfRatingsLabel.right(adaptConstant(20))
        
        ratingControl.right(adaptConstant(20)).bottom(adaptConstant(24))
        ratingControl.rating = 0
        
        tapToRateLabel.CenterY == ratingControl.CenterY
        tapToRateLabel.CenterX == ratingLabelStackView.CenterX
        
        errorText.left(0).right(0)
        errorText.CenterY == ratingControl.CenterY
        
        ratingControl.didFinishTouchingCosmos = { rating in
            self.submitRating(Int(rating))
        }
    }
    
    func submitRating(_ rating: Int) {        
        if aboutCell!.review != nil {
            aboutCell!.review?.rating = rating
            FirebaseController.shared.saveReview(aboutCell!.review!, forRecipeID: aboutCell!.recipeID)
        } else {
            let uid = UUID().uuidString
            let review = Review(uid: uid, dictionary: ["rating": rating])
            FirebaseController.shared.saveReview(review, forRecipeID: aboutCell!.recipeID)
        }
        
//        NotificationCenter.default.post(name: Notification.Name("submittedReview"), object: nil)
//        NotificationCenter.default.post(name: Notification.Name("FavoritesChanged"), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
