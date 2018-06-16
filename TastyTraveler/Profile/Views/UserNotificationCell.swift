//
//  UserNotificationCell.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/21/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia

class UserNotificationCell: UITableViewCell {
    
    var notification: UserNotification? {
        didSet {
            if let url = notification?.user.avatarURL {
                self.avatarImageView.loadImage(urlString: url, placeholder: #imageLiteral(resourceName: "avatar"))
            }
            
            let userStringRange = (notification!.message as NSString).range(of: notification!.user.username)
            let attributedString = NSMutableAttributedString(string: notification!.message, attributes: [NSAttributedStringKey.font: ProximaNova.regular.of(size: 14)])
            
            attributedString.setAttributes([NSAttributedStringKey.font: ProximaNova.bold.of(size: 14), NSAttributedStringKey.foregroundColor: UIColor.black], range: userStringRange)
            
            self.notificationText.attributedText = attributedString
            
            //if let recipePhotoURL = notification?.photoURL {
            //    self.recipePhotoImageView.isHidden = false
            if let recipePhotoURL = notification?.photoURL {
                self.recipePhotoImageView.loadImage(urlString: recipePhotoURL, placeholder: #imageLiteral(resourceName: "imagePlaceholder"))
            }
           //     photoConstraint.isActive = true
           // } else {
           //     noPhotoConstraint.isActive = true
           //     self.recipePhotoImageView.isHidden = true
           // }
        }
    }
    
    let avatarImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.width(adaptConstant(40)).height(adaptConstant(40))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = adaptConstant(20)
        imageView.image = #imageLiteral(resourceName: "avatar")
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let notificationText: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    let recipePhotoImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.width(adaptConstant(40)).height(adaptConstant(40))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = adaptConstant(8)
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
//    lazy var noPhotoConstraint = NSLayoutConstraint(item: notificationText, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 12)
//    lazy var photoConstraint = NSLayoutConstraint(item: notificationText, attribute: .trailing, relatedBy: .equal, toItem: recipePhotoImageView, attribute: .leading, multiplier: 1, constant: 8)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        sv(avatarImageView, notificationText, recipePhotoImageView)
        
        avatarImageView.left(12).centerVertically().top(12).bottom(12)
        notificationText.centerVertically()
        notificationText.Left == avatarImageView.Right + 8
        notificationText.Right == recipePhotoImageView.Left - 8
        
        recipePhotoImageView.right(12).centerVertically()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.avatarImageView.image = #imageLiteral(resourceName: "avatar")
    }
}


