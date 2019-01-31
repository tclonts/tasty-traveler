//
//  UserFollowerInfo.swift
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


class FollowersInfoTableVC: UITableViewController {

   
    var user: TTUser? {
        didSet{
            self.user = ProfileVC.shared.user
        }
    }

    let navigationBarBackground: GradientView = {
        let gradientView = GradientView()
        gradientView.startPointX = 0.5
        gradientView.startPointY = 0
        gradientView.endPointX = 0.5
        gradientView.endPointY = 1
        gradientView.topColor = UIColor.black.withAlphaComponent(0.64)
        gradientView.bottomColor = UIColor.black.withAlphaComponent(0)
        return gradientView
    }()
    
    let navigationBar: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "closeButton"), for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
        override func viewDidLoad() {
            super.viewDidLoad()
            self.tableView.reloadData()
            self.view.backgroundColor = .white
            self.user = ProfileVC.shared.user
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
            
            self.tableView.register(FollowersCell.self, forCellReuseIdentifier: "followersCell")

        }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    @objc func backButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            guard let currentUserID = Auth.auth().currentUser?.uid else { return 0 }

            if (self.user?.followers) != nil {
            let userDictionary = self.user?.followers?.compactMap { $0.key }

            for userID in (userDictionary!) {
                if userID == currentUserID {
                    EmptyMessage(message: "You do not have any followers yet!")
                    return 0
                } else if (user?.followers?.count) != nil && ((user?.followers?.count)!) > 0 {
                    return (user?.followers?.count)!
            }
        }
    }
            EmptyMessage(message: "You do not have any followers yet!")
            return 0
    }
        override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 72
        }
    
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "followersCell", for: indexPath) as! FollowersCell
            guard let currentUserID = Auth.auth().currentUser?.uid else { return UITableViewCell() }
            let userDictionary = self.user?.followers?.compactMap { $0.key }
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
    
   
extension FollowersInfoTableVC {
    
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



