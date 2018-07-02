//
//  ChatMessageCell.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/2/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit

class ChatMessageCell: UITableViewCell {
    
    var message: Message?
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.regular.of(size: 16)
        label.numberOfLines = 0
        label.textColor = .white
        label.backgroundColor = .clear
        return label
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.primaryOrange
        view.layer.cornerRadius = adaptConstant(16)
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.layer.cornerRadius = adaptConstant(16)
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = #imageLiteral(resourceName: "avatar")
        return imageView
    }()
    
    var bubbleViewWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        sv(bubbleView.sv(messageLabel), profileImageView)
        
        profileImageView.left(adaptConstant(8)).bottom(0).width(adaptConstant(32)).height(adaptConstant(32))
        
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -adaptConstant(8))
        bubbleViewRightAnchor?.isActive = true
        
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: adaptConstant(8))
        
        bubbleViewWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: adaptConstant(200))
        bubbleViewWidthAnchor?.isActive = true
        
        bubbleView.top(adaptConstant(8)).bottom(0)
        
        messageLabel.left(adaptConstant(12)).right(adaptConstant(12)).top(adaptConstant(8)).bottom(adaptConstant(8))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
