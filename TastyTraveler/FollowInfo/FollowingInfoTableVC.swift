//
//  FollowingInfoTableVC.swift
//  TastyTraveler
//
//  Created by Tyler Clonts on 1/30/19.
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


class FollowingInfoTableVC: UITableViewController {
    
    
    var user: TTUser?
    
    
    let emptyLabel = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                    self.tableView.reloadData()
        self.view.backgroundColor = .white
        
        FirebaseController.shared.fetchUserWithUID(uid: (user?.uid)!) { (user) in
            guard let user = user else {return}
            self.user = user
            let username = user.username
            self.navigationItem.title = username
        }
        
        
        self.tableView.contentInsetAdjustmentBehavior = .never
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Color.blackText, NSAttributedStringKey.font: UIFont(name: "ProximaNova-Bold", size: adaptConstant(20))!]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = .white
        
        self.tableView.register(FollowingCell.self, forCellReuseIdentifier: "followingCell")
        let footerView = UIView()
        footerView.backgroundColor = .white
        footerView.height(1)
        self.tableView.tableFooterView = footerView

    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let currentUserID = Auth.auth().currentUser?.uid else { return 0 }
        
        if (self.user?.following) != nil {
            let userDictionary = self.user?.following?.compactMap { $0.key }
            
            for userID in (userDictionary!) {
                if userID == currentUserID {
                    EmptyMessage(message: "You are not following anyone yet")
                    return 0
                } else if (user?.following?.count) != nil && ((user?.following?.count)!) > 0 {
                    return (user?.following?.count)!
                }
            }
        }
        EmptyMessage(message: "You are not following anyone yet")
        return 0
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "followingCell", for: indexPath) as! FollowingCell
        guard let currentUserID = Auth.auth().currentUser?.uid else { return UITableViewCell() }
        let userDictionary = self.user?.following?.compactMap { $0.key }
        let userID = userDictionary?[indexPath.row]
        cell.oldUser = self.user
        
        FirebaseController.shared.fetchUserWithUID(uid: userID!) { (user) in
            guard let user = user else {return}
            
            if userID != currentUserID {
                cell.user = user
            }
        }
        
        return cell
        
    }
}

//        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//            let message = FirebaseController.shared.messages[indexPath.row]
//
//
//            guard let chatPartnerID = message.chatPartnerID() else { return }
//            SVProgressHUD.show()
//            FirebaseController.shared.fetchUserWithUID(uid: chatPartnerID) { (user) in
//                guard let user = user else { return }
//                guard let recipeID = message.recipeID, recipeID != "" else {
//                    let chat = Chat(recipe: nil, withUser: user)
//                    self.showChatControllerForChat(chat)
//                    return
//                }
//                FirebaseController.shared.fetchRecipeWithUID(uid: recipeID, completion: { (recipe) in
//                    guard let recipe = recipe else { return }
//                    let chat = Chat(recipe: recipe, withUser: user)
//                    self.showChatControllerForChat(chat)
//                })
//            }
//        }


extension FollowingInfoTableVC {
    
    func EmptyMessage(message:String) {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        
        tableView.backgroundView = messageLabel;
        tableView.separatorStyle = .none;
    }
}



