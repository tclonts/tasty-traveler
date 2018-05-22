//
//  CommentCell.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/14/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia

class CommentCell: UITableViewCell {
    
    let avatarImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.semibold.of(size: 16)
        label.textColor = Color.darkText
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.regular.of(size: 14)
        label.textColor = Color.gray
        return label
    }()
    
    let commentTextLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.regular.of(size: 16)
        label.textColor = Color.darkText
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        sv(avatarImageView, usernameLabel, dateLabel, commentTextLabel)
        
        avatarImageView.left(0).top(0).height(adaptConstant(40)).width(adaptConstant(40))
        
        usernameLabel.Left == avatarImageView.Right + adaptConstant(8)
        usernameLabel.Top == avatarImageView.Top
        
        dateLabel.right(0)
        dateLabel.CenterY == usernameLabel.CenterY
        
        commentTextLabel.Top == usernameLabel.Bottom + adaptConstant(12)
        commentTextLabel.Left == usernameLabel.Left
        commentTextLabel.right(0).bottom(0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
