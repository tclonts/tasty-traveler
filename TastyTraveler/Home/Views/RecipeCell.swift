//
//  RecipeCell.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/15/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia

class RecipeCell: UITableViewCell {
    
    var recipe: Recipe? {
        didSet {
            guard let photoURL = recipe?.photoURL else { return }
            recipeHeaderView.photoImageView.loadImage(urlString: photoURL, placeholder: nil)
            
            if let countryCode = recipe?.countryCode, let locality = recipe?.locality {
                recipeHeaderView.countryFlag.image = UIImage(named: countryCode)
                recipeHeaderView.countryLabel.text = "\(locality), \(countryCode)"
            } else {
                recipeHeaderView.countryFlag.image = nil
                recipeHeaderView.countryLabel.text = "Location Unavailable"
            }

            if let meal = recipe?.meal {
                self.recipeHeaderView.mealLabel.text = "  \(meal)  "
            }
            
            recipeHeaderView.recipeNameLabel.text = recipe?.name
            recipeHeaderView.creatorNameLabel.text = "by \(recipe!.creator.username)"

            recipe!.averageRating { (rating) in
                self.recipeHeaderView.starRating.rating = rating
                self.recipeHeaderView.starRating.text = "(\(self.recipe!.reviewsDictionary?.count ?? 0))"
            }

            recipeHeaderView.favoriteButton.setImage(recipe?.hasFavorited == true ? #imageLiteral(resourceName: "favoriteButtonSelected") : #imageLiteral(resourceName: "favoriteButton"), for: .normal)
        }
    }
    
    lazy var shadowView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = adaptConstant(12)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: adaptConstant(10))
        view.layer.shadowRadius = adaptConstant(25)
        return view
    }()
    
    let recipeHeaderView = RecipeHeaderView()
    weak var delegate: RecipeCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        sv(shadowView.sv(recipeHeaderView))
        
        shadowView.top(0).left(adaptConstant(18)).right(adaptConstant(18)).bottom(adaptConstant(20))
        recipeHeaderView.fillContainer()
        recipeHeaderView.layer.cornerRadius = adaptConstant(12)
        recipeHeaderView.clipsToBounds = true
        recipeHeaderView.layer.masksToBounds = true
        recipeHeaderView.backgroundColor = .white
        
        recipeHeaderView.photoImageView.top(0).left(0).right(0)
        recipeHeaderView.photoImageView.Height == recipeHeaderView.photoImageView.Width * 0.75
        
        recipeHeaderView.placeholderImageView.CenterY == recipeHeaderView.photoImageView.CenterY
        recipeHeaderView.placeholderImageView.CenterX == recipeHeaderView.photoImageView.CenterX
        
        recipeHeaderView.mealLabel.left(0)
        recipeHeaderView.mealLabel.Bottom == recipeHeaderView.photoImageView.Bottom - adaptConstant(27)
        recipeHeaderView.mealLabel.height(adaptConstant(20))
        
        recipeHeaderView.countryFlag.left(adaptConstant(10))
        recipeHeaderView.countryFlag.Top == recipeHeaderView.photoImageView.Bottom + adaptConstant(12)
        recipeHeaderView.countryLabel.Left == recipeHeaderView.countryFlag.Right + adaptConstant(4)
        recipeHeaderView.countryLabel.CenterY == recipeHeaderView.countryFlag.CenterY
        
        recipeHeaderView.recipeNameLabel.left(adaptConstant(10)).right(adaptConstant(10))
        recipeHeaderView.recipeNameLabel.Top == recipeHeaderView.countryFlag.Bottom + adaptConstant(8)
        
        recipeHeaderView.creatorNameLabel.left(adaptConstant(10))
        recipeHeaderView.creatorNameLabel.Top == recipeHeaderView.recipeNameLabel.Bottom + adaptConstant(8)
        recipeHeaderView.creatorNameLabel.bottom(adaptConstant(12))
        
        recipeHeaderView.favoriteButton.right(adaptConstant(14))
        recipeHeaderView.favoriteButton.CenterY == recipeHeaderView.photoImageView.Bottom
        
        recipeHeaderView.starRating.right(adaptConstant(10))
        recipeHeaderView.starRating.CenterY == recipeHeaderView.creatorNameLabel.CenterY
        
        recipeHeaderView.favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
    }
    
    @objc func favoriteTapped() {
        delegate?.didTapFavorite(for: self)
    }
    
    override func prepareForReuse() {
        recipeHeaderView.heroID = ""
        recipeHeaderView.starRating.rating = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shadowView.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        
        self.layoutIfNeeded()
    }
}

protocol RecipeCellDelegate: class {
    func didTapFavorite(for cell: RecipeCell)
}
