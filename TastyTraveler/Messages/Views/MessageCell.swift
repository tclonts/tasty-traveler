//
//  MessageCell.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/2/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia
import FirebaseAuth

class MessageCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            setUpNameAndProfileImage()
            
            detailTextLabel?.text = message?.text
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            
            if message!.toID == Auth.auth().currentUser!.uid  {
                if message!.isUnread {
                    unreadIndicatorView.isHidden = false
                } else {
                    unreadIndicatorView.isHidden = true
                }
            }
            
            if let date = message?.timestamp {
                timeLabel.text = dateFormatter.string(from: date)
            }
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
    
    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = adaptConstant(20)
        imageView.layer.masksToBounds = true
        imageView.image = #imageLiteral(resourceName: "avatar")
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.regular.of(size: 12)
        label.text = ""
        label.textColor = Color.gray
        return label
    }()
    
    let disclosureIndicator: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "disclosureIndicator")
        imageView.contentMode = .scaleAspectFit
        imageView.height(adaptConstant(14)).width(adaptConstant(9))
        return imageView
    }()
    
    func setUpNameAndProfileImage() {
        if let id = message?.chatPartnerID() {
            let ref = FirebaseController.shared.ref.child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String:Any] {
                    self.textLabel?.text = dictionary["username"] as? String
                    
                    if let profileImageURL = dictionary["avatarURL"] as? String {
                        self.profileImageView.loadImage(urlString: profileImageURL, placeholder: #imageLiteral(resourceName: "avatar"))
                    }
                }
            })
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: adaptConstant(75), y: textLabel!.frame.origin.y - adaptConstant(2), width: textLabel!.frame.width, height: textLabel!.frame.height)
        timeLabel.CenterY == textLabel!.CenterY
        timeLabel.Right == disclosureIndicator.Left - adaptConstant(12)
        disclosureIndicator.CenterY == timeLabel.CenterY
        detailTextLabel?.frame = CGRect(x: adaptConstant(75), y: detailTextLabel!.frame.origin.y + adaptConstant(2), width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
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
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//
//        self.unreadIndicatorView.isHidden = true
//    }
}
