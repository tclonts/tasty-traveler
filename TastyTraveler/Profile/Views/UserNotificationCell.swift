//
//  UserNotificationCell.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/21/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit

class UserNotificationCell: UITableViewCell {
    
    let avatarImageView: CustomImageView = {
        let imageView = CustomImageView()
        return imageView
    }()
    
    let notificationText: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let recipePhotoImageView: CustomImageView = {
        let imageView = CustomImageView()
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


