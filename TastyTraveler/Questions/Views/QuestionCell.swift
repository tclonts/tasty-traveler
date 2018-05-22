//
//  QuestionCell.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/1/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia

class QuestionCell: UITableViewCell {
    
    var question: Question? {
        didSet {
            self.textLabel?.text = question!.user!.username
            self.detailTextLabel?.text = question!.lastMessage!.text
            
            self.unreadIndicatorView.isHidden = !question!.lastMessage!.isUnread
        }
    }
    
    let unreadIndicatorView: UIView = {
        let view = UIView()
        view.height(adaptConstant(11)).width(adaptConstant(11))
        view.backgroundColor = Color.primaryOrange
        view.layer.cornerRadius = adaptConstant(11) / 2
        view.layer.masksToBounds = true
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = adaptConstant(20)
        imageView.layer.masksToBounds = true
        imageView.image = #imageLiteral(resourceName: "avatar")
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.regular.of(size: 12)
        label.text = "16:45"
        label.textColor = Color.gray
        return label
    }()
    
    let disclosureIndicator: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "disclosureIndicator")
        imageView.contentMode = .scaleAspectFit
        imageView.height(14).width(9)
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: adaptConstant(75), y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        timeLabel.CenterY == textLabel!.CenterY
        timeLabel.Right == disclosureIndicator.Left - 12
        disclosureIndicator.CenterY == timeLabel.CenterY
        detailTextLabel?.frame = CGRect(x: adaptConstant(75), y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        sv(profileImageView, timeLabel, unreadIndicatorView, disclosureIndicator)
        
        unreadIndicatorView.left(adaptConstant(8)).centerVertically()
        
        profileImageView.left(adaptConstant(27)).height(adaptConstant(40)).width(adaptConstant(40)).centerVertically()
        
        disclosureIndicator.right(adaptConstant(12))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
