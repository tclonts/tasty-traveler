//
//  RecipeCell.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/15/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia
import Firebase

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
            
//            recipeHeaderView.creatorNameLabel.text = "by \(recipe!.creator.username)"

            recipe!.averageRating { (rating) in
                self.recipeHeaderView.starRating.rating = rating
                self.recipeHeaderView.starRating.text = "(\(self.recipe!.reviewsDictionary?.count ?? 0))"
            }

            recipeHeaderView.favoriteButton.setImage(recipe?.hasFavorited == true ? #imageLiteral(resourceName: "favoriteButtonSelected") : #imageLiteral(resourceName: "favoriteButton"), for: .normal)
            recipeHeaderView.likeButton.setImage(recipe?.hasLiked == true ? #imageLiteral(resourceName: "likeNavSelected") : #imageLiteral(resourceName: "likeNav"), for: .normal)

   
//            self.setFollowButton()

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
        
//        setFollowButton()
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
        
        recipeHeaderView.stackView2.left(adaptConstant(10))
        recipeHeaderView.stackView2.Top == recipeHeaderView.recipeNameLabel.Bottom + adaptConstant(8)
        recipeHeaderView.stackView2.bottom(adaptConstant(12))
//        recipeHeaderView.stackView2.Height == recipeHeaderView.starRating.Height
        
        recipeHeaderView.favoriteButton.right(adaptConstant(14))
        recipeHeaderView.favoriteButton.CenterY == recipeHeaderView.photoImageView.Bottom
        
        recipeHeaderView.starRating.right(adaptConstant(10))
        recipeHeaderView.starRating.CenterY == recipeHeaderView.stackView2.CenterY
        
//        recipeHeaderView.followButton.Left == recipeHeaderView.creatorNameLabel.Right + 8
//        recipeHeaderView.followButton.Width == recipeHeaderView.starRating.Width - 8
//        recipeHeaderView.followButton.Height == recipeHeaderView.creatorNameLabel.Height
//        recipeHeaderView.followButton.CenterY == recipeHeaderView.creatorNameLabel.CenterY

        
        recipeHeaderView.favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        recipeHeaderView.likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        recipeHeaderView.followButton.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)

    }
    
    @objc func favoriteTapped() {
        delegate?.didTapFavorite(for: self)
    }
    @objc func likeTapped() {
        delegate?.didTapLike(for: self)
    }
    @objc func followButtonTapped() {
        delegate?.didTapFollowButton(for: self)
    }
    override func prepareForReuse() {
        recipeHeaderView.heroID = ""
        recipeHeaderView.starRating.rating = 0
    }
    func setFollowButton() {
        guard let currentUser = Auth.auth().currentUser?.uid else { return }
        
        FirebaseController.shared.fetchUserWithUID(uid: currentUser) { (user) in
            guard let user = user else {return}
            var updatedUser = user
            FirebaseController.shared.ref.child("users").child(currentUser).child("following").child(((self.recipe?.creator.uid)!)).observeSingleEvent(of: .value) { (snapshot) in
                if (snapshot.value as? Double) != nil {
                    updatedUser.hasFollowed = true
                } else {
                    updatedUser.hasFollowed = false
                }
                
                
                if ((updatedUser.hasFollowed)) {
                    let title = NSAttributedString(string: "Following", attributes: [
                        NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(10))!,
                        NSAttributedStringKey.foregroundColor: Color.gray])
                    self.recipeHeaderView.followButton.backgroundColor = UIColor.white
                    self.recipeHeaderView.followButton.layer.borderColor = Color.gray.cgColor
                    self.recipeHeaderView.followButton.layer.borderWidth = 1.0
//                    self.recipeHeaderView.followButton.Height == self.recipeHeaderView.creatorNameLabel.Height
                    self.recipeHeaderView.followButton.setAttributedTitle(title, for: .normal)
                    self.recipeHeaderView.creatorNameLabel.text = "by \(self.recipe!.creator.username)"
                    self.recipeHeaderView.creatorNameLabel.textColor = Color.primaryOrange


                } else {
                    let title = NSAttributedString(string: "Follow", attributes: [
                        NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(10))!,
                        NSAttributedStringKey.foregroundColor: Color.primaryOrange])
                    self.recipeHeaderView.followButton.backgroundColor = Color.offWhite
                    self.recipeHeaderView.followButton.layer.borderColor = Color.primaryOrange.cgColor
                    self.recipeHeaderView.followButton.layer.borderWidth = 1.0
//                    self.recipeHeaderView.followButton.Height == self.recipeHeaderView.creatorNameLabel.Height
                    self.recipeHeaderView.followButton.setAttributedTitle(title, for: .normal)
                    self.recipeHeaderView.creatorNameLabel.text = "by \(self.recipe!.creator.username)"
                    self.recipeHeaderView.creatorNameLabel.textColor = Color.darkGrayText
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setFollowButton()
        shadowView.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layoutIfNeeded()
    }
}

protocol RecipeCellDelegate: class {
    func didTapFavorite(for cell: RecipeCell)
    func didTapLike(for cell: RecipeCell)
    func didTapFollowButton(for cell: RecipeCell)
}
