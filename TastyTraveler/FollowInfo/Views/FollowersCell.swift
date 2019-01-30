//
//  FollowersCell.swift
//  TastyTraveler
//
//  Created by Tyler Clonts on 1/27/19.
//  Copyright © 2019 Michael Bart. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GSKStretchyHeaderView
import Stevia
import RSKImageCropper
import SVProgressHUD
import Hero
import AVKit
import FirebaseAuth
import SVProgressHUD
import CoreLocation
import MapKit
import Social
import FacebookShare
import FacebookCore
import RSKImageCropper

class FollowersCell: UITableViewCell {
    
    
    var userID: String?
    var oldUser: TTUser?

    
    var user: TTUser? {
            didSet {
               
                setFollowButton()
                
                if let username = user?.username {
                    self.usernameLabel.text = username
                }
                if let url = user?.avatarURL {
                    self.profilePhotoImageView.loadImage(urlString: url, placeholder: #imageLiteral(resourceName: "avatar"))
                }
                
        }
    }

//    let navigationBarBackground: UIView = {
//        let view = UIView()
//        view.backgroundColor = .white
//        return view
//    }()
    
//    let navigationBar: UIView = {
//        let view = UIView()
//        view.backgroundColor = .white
//        let separator = UIView()
//        separator.backgroundColor = Color.lightGray
//        
//        view.sv(separator)
//        separator.bottom(0).left(0).right(0).height(0.5)
//        return view
//    }()
    
    let countryFlagImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.height(15).width(22)
        return imageView
    }()
    
    let countryLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.semibold.of(size: 12)
        label.textColor = Color.darkGrayText
        return label
    }()
    
    
    let profilePhotoImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.image = #imageLiteral(resourceName: "avatar")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = adaptConstant(20)
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = Color.primaryOrange.cgColor
        return imageView
    }()
    
//    lazy var backButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setImage( imageLiteral(resourceName: "backButton"), for: .normal)
//        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
//        return button
//    }()
    
//    lazy var backButtonNav: UIButton = {
//        let button = UIButton(type: .system)
//        button.setImage( imageLiteral(resourceName: "backButtonNav"), for: .normal)
//        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
//        return button
//    }()
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = ProximaNova.regular.of(size: 13)
        let title = NSAttributedString(string: "Follow", attributes: [
            NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
            NSAttributedStringKey.foregroundColor: Color.offWhite])
        button.backgroundColor = Color.primaryOrange
        button.setAttributedTitle(title, for: .normal)
        return button
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.bold.of(size: 16)
        label.textColor = Color.blackText
        label.text = "Username"
        return label
    }()
    
    func setUpNameAndProfileImage() {
        
        let ref = FirebaseController.shared.ref.child("users").child(userID!)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in

                if let dictionary = snapshot.value as? [String:Any] {
                    self.usernameLabel.text = dictionary["username"] as? String
                    
                    if let profileImageURL = dictionary["avatarURL"] as? String {
                        self.profilePhotoImageView.loadImage(urlString: profileImageURL, placeholder: #imageLiteral(resourceName: "avatar"))
                    }
                }
            })
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()

    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        let flagStackView = UIStackView(arrangedSubviews: [countryFlagImageView, countryLabel])
        flagStackView.axis = .horizontal
        flagStackView.spacing = 8
        
        sv(profilePhotoImageView, usernameLabel, countryLabel, countryFlagImageView, flagStackView, followButton)
        
        profilePhotoImageView.left(adaptConstant(27)).height(adaptConstant(40)).width(adaptConstant(40)).centerVertically()
        
        usernameLabel.CenterY == profilePhotoImageView.CenterY - 12
        usernameLabel.Left == profilePhotoImageView.Right + 12
        
        flagStackView.Top == usernameLabel.Bottom - 12
        
        followButton.right(adaptConstant(27)).height(adaptConstant(30)).width(adaptConstant(85))
        followButton.CenterY == profilePhotoImageView.CenterY
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func followButtonTapped() {
        followFunction()
    }
    
    func setFollowButton() {
        guard let currentUser = Auth.auth().currentUser?.uid else { return }
        
        FirebaseController.shared.fetchUserWithUID(uid: currentUser) { (user) in
            guard let user = user else {return}
            var updatedUser = user
        FirebaseController.shared.ref.child("users").child(currentUser).child("following").child((self.user!.uid)).observeSingleEvent(of: .value) { (snapshot) in
    if (snapshot.value as? Double) != nil {
        updatedUser.hasFollowed = true
    } else {
        updatedUser.hasFollowed = false
    }
            
            
            if ((updatedUser.hasFollowed)) {
    let title = NSAttributedString(string: "Following", attributes: [
    NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
    NSAttributedStringKey.foregroundColor: Color.gray])
    self.followButton.backgroundColor = UIColor.white
    self.followButton.layer.borderColor = Color.gray.cgColor
    self.followButton.layer.borderWidth = 2.0
    
    self.followButton.setAttributedTitle(title, for: .normal)
    } else {
    let title = NSAttributedString(string: "Follow", attributes: [
    NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
    NSAttributedStringKey.foregroundColor: Color.offWhite])
    self.followButton.backgroundColor = Color.primaryOrange
    self.followButton.setAttributedTitle(title, for: .normal)
            }
        }
    }
}
    
    func followFunction() {
        guard let currentUser = Auth.auth().currentUser?.uid else { return }
        
        FirebaseController.shared.fetchUserWithUID(uid: currentUser) { (user) in
            guard let user = user else {return}
            var updatedUser = user
            
            FirebaseController.shared.ref.child("users").child(currentUser).child("following").child(self.user!.uid).observeSingleEvent(of: .value) { (snapshot) in
                if (snapshot.value as? Double) != nil {
                    updatedUser.hasFollowed = true
                } else {
                    updatedUser.hasFollowed = false
                }
                
                
                if (updatedUser.hasFollowed) {
                    // remove
                    FirebaseController.shared.ref.child("users").child(self.user!.uid).child("followers").child(currentUser).removeValue()
                    FirebaseController.shared.ref.child("users").child(currentUser).child("following").child(self.user!.uid).removeValue()
                    
                    SVProgressHUD.showSuccess(withStatus: "Unfollowed")
                    SVProgressHUD.dismiss(withDelay: 1)
                    
                    let title = NSAttributedString(string: "Follow", attributes: [
                        NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
                        NSAttributedStringKey.foregroundColor: Color.offWhite])
                    self.followButton.backgroundColor = Color.primaryOrange
                    self.followButton.layer.borderColor = Color.primaryOrange.cgColor
                    self.followButton.layer.borderWidth = 1.0
                    self.followButton.setAttributedTitle(title, for: .normal)
                    
                } else {
                    //ADD
                    
                    FirebaseController.shared.ref.child("users").child(self.user!.uid).child("followers").child(currentUser).setValue(true) { (error, _) in
                        if let error = error {
                            print("Failed to add current user to tableview cell user:", error)
                            return
                        }
                        
                        let timestamp = Date().timeIntervalSince1970
                        
                        FirebaseController.shared.ref.child("users").child(currentUser).child("following").child(self.user!.uid).setValue(timestamp) { (error, _) in
                            if let error = error {
                                print("Failed to add tableview cell user:", error)
                                return
                            }
                            SVProgressHUD.showSuccess(withStatus: "Followed")
                            SVProgressHUD.dismiss(withDelay: 1)
                            
                            let title = NSAttributedString(string: "Following", attributes: [
                                NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
                                NSAttributedStringKey.foregroundColor: Color.gray])
                            self.followButton.backgroundColor = UIColor.white
                            self.followButton.layer.borderColor = UIColor.gray.cgColor
                            self.followButton.layer.borderWidth = 2.0
                            self.followButton.setAttributedTitle(title, for: .normal)
                        }
                    }
                }
            }
        }
}
}
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//
//        self.profilePhotoImageView.image = #imageLiteral(resourceName: "avatar")
//    }

