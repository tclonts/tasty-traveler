//
//  File.swift
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


class TestUIViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
//    func presentProfileViewController() {
//        let profileVC = ProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
//        profileVC.isMyProfile = false
//        profileVC.userID = user?.uid
//        self.present(profileVC, animated: true, completion: nil)
//    }
    
  
    
    var user: TTUser?
    var newUser: String?
    var fromFollowingButtonNav = false
    var fromFollowersButtonNav = false
    

    
    
//    let navigationBarBackground: GradientView = {
//        let gradientView = GradientView()
//        gradientView.startPointX = 0.5
//        gradientView.startPointY = 0
//        gradientView.endPointX = 0.5
//        gradientView.endPointY = 1
//        gradientView.topColor = UIColor.black.withAlphaComponent(0.64)
//        gradientView.bottomColor = UIColor.black.withAlphaComponent(0)
//        return gradientView
//    }()
//
//    let navigationBar: UIView = {
//        let view = UIView()
//        view.backgroundColor = .clear
//        return view
//    }()

    lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "closeButton"), for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var followersButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(followersButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = ProximaNova.regular.of(size: adaptConstant(10))
        
        button.setTitle("followers", for: .normal)
        button.setTitleColor(Color.primaryOrange, for: .normal)
        button.titleLabel?.font = UIFont(name: "ProximaNova-Regular", size: adaptConstant(10))!
        
        return button
    }()
    lazy var followingButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(followingButtonTapped), for: .touchUpInside)

        button.setTitleColor(Color.primaryOrange, for: .normal)
        button.setTitle("following", for: .normal)
        button.titleLabel?.font = ProximaNova.regular.of(size: adaptConstant(10))

        return button
    }()
    let followersCountLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.bold.of(size: 16)
        label.textColor = Color.blackText
        label.text = "\(0)"
        return label
    }()
    let followingCountLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.bold.of(size: 16)
        label.textColor = Color.blackText
        label.text = "\(0)"
        return label
    }()
    
    
    lazy var followersTableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 75
        tableView.allowsSelection = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(FollowersCell.self, forCellReuseIdentifier: "followersCell")
        return tableView
    }()
    lazy var followingTableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 75
        tableView.allowsSelection = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(FollowingCell.self, forCellReuseIdentifier: "followingCell")
        return tableView
    }()
    
    lazy var line1: UIView = {
       let separator = UIView()
        separator.layer.backgroundColor = Color.primaryOrange.cgColor
        separator.height(1)
        
        return separator
    }()
    lazy var line2: UIView = {
        let separator = UIView()
        separator.layer.backgroundColor = Color.primaryOrange.cgColor
        separator.height(1)
        
        return separator
    }()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTV), name: Notification.Name("switchedTVs"), object: nil)
        
        self.followersTableView.reloadData()
        self.followingTableView.reloadData()
        followersTableView.delegate = self
        followingTableView.delegate = self
        followersTableView.dataSource = self
        followingTableView.dataSource = self


        FirebaseController.shared.fetchUserWithUID(uid: (user?.uid)!) { (user) in
            guard let user = user else {return}
            self.user = user
            let username = user.username
            self.navigationItem.title = username
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backButton)
            
        }
        
        
        if let followersCount = user?.followers {
            self.followersCountLabel.text = "\(followersCount.count)"
            
        }
        if let followingCount = user?.following {
            self.followingCountLabel.text = "\(followingCount.count)"
        }
        
        let followersStackView = UIStackView(arrangedSubviews: [followersCountLabel, followersButton, line1])
        followersStackView.axis = .vertical
        followersStackView.spacing = 0
        followersStackView.alignment = .center
        line1.Width == followersStackView.Width/2.0

        
        let followingStackView = UIStackView(arrangedSubviews: [followingCountLabel, followingButton, line2])
        followingStackView.axis = .vertical
        followingStackView.spacing = 0
        followingStackView.alignment = .center
        line2.Width == followingStackView.Width/2

        let flagStackView = UIStackView(arrangedSubviews: [countryFlagImageView, countryLabel])
        flagStackView.axis = .horizontal
        flagStackView.spacing = 8
        
//        self.tableView.contentInsetAdjustmentBehavior = .never
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Color.blackText, NSAttributedStringKey.font: UIFont(name: "ProximaNova-Bold", size: adaptConstant(20))!]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")

        
        if fromFollowersButtonNav == true{
            self.view.sv(followersTableView, followersStackView, followingStackView)
            line2.isHidden = true
            
            self.followersButton.titleLabel?.textColor = Color.primaryOrange
            self.followersCountLabel.textColor = UIColor.black
            //            followingButton.titleLabel?.textColor = Color.gray
            self.followingButton.setTitleColor(Color.gray, for: .normal)
            self.followingCountLabel.textColor = Color.gray
            
            followersTableView.isScrollEnabled = true
            
            
        } else if fromFollowingButtonNav == true {
            self.view.sv(followingTableView, followersStackView, followingStackView)
            line1.isHidden = true
            
            followingButton.titleLabel?.textColor = Color.primaryOrange
            followingCountLabel.textColor = UIColor.black
            //            followersButton.titleLabel?.textColor = Color.gray
            followersButton.setTitleColor(Color.gray, for: .normal)
            followersCountLabel.textColor = Color.gray
            
            followingTableView.isScrollEnabled = true
            
        }
        
        
        let width = UIScreen.main.bounds.width / 2
        followersStackView.width(width)
        followersStackView.height(40)
        followersStackView.left(0).top(0)

        
        followingStackView.width(width)
        followingStackView.height(40)
        followingStackView.right(0).top(0)
        
        followersTableView.Top == followersStackView.Bottom + 8
        followersTableView.left(0).right(0).bottom(0)

        followingTableView.Top == followersStackView.Bottom + 8
        followingTableView.left(0).right(0).bottom(0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
            self.followersTableView.reloadData()
            self.followingTableView.reloadData()
              NotificationCenter.default.addObserver(self, selector: #selector(reloadTV), name: Notification.Name("switchedTVs"), object: nil)

    }
    
    @objc func reloadTV() {
        DispatchQueue.main.async {
            self.followingTableView.reloadData()
            self.followersTableView.reloadData()
        }
    }
    
    @objc func followersButtonTapped() {
        followersTableView.isHidden = false
        followingTableView.isHidden = true
        line2.isHidden = true
        line1.isHidden = false
        followersCountLabel.textColor = UIColor.black
        followersButton.setTitleColor(Color.primaryOrange, for: .normal)
        followingCountLabel.textColor = Color.gray
        followingButton.titleLabel?.textColor = Color.gray
        
        NotificationCenter.default.post(name: Notification.Name("switchedTVs"), object: nil)


        followersTableView.isScrollEnabled = true
    }
    
    @objc func followingButtonTapped() {
  
            self.followersTableView.isHidden = true
            self.followingTableView.isHidden = false
            self.line2.isHidden = false
            self.line1.isHidden = true
            self.followersCountLabel.textColor = Color.gray
            self.followersButton.titleLabel?.textColor = Color.gray
            self.followingCountLabel.textColor =  UIColor.black
            self.followingButton.setTitleColor(Color.primaryOrange, for: .normal)

        NotificationCenter.default.post(name: Notification.Name("switchedTVs"), object: nil)

       
        followingTableView.isScrollEnabled = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    @objc func backButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let currentUserID = Auth.auth().currentUser?.uid else { return 0 }
        
        if tableView == followersTableView {
        
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
            
        } else if tableView == followingTableView {
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
        } else {
            return 0
        }
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == followersTableView {
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
        
        } else if tableView == followingTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "followingCell", for: indexPath) as! FollowingCell
            guard let currentUserID = Auth.auth().currentUser?.uid else { return UITableViewCell() }
            let userDictionary = self.user?.following?.compactMap { $0.key }
            let userID = userDictionary?[indexPath.row]
            cell.oldUser = self.user
        
            cell.completionHandler = {
                let profileVC = ProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
                profileVC.isMyProfile = false
                profileVC.userID = userID
                
                self.present(profileVC, animated: true, completion: nil)

            }
            
            FirebaseController.shared.fetchUserWithUID(uid: userID!) { (user) in
                guard let user = user else {return}
                
                if userID != currentUserID {
                    cell.user = user
                }
            }
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
}


extension TestUIViewController {
    
    func EmptyMessage(message:String) {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "ProximaNova-Regular", size: 15)
        messageLabel.sizeToFit()
        
        followersTableView.backgroundView = messageLabel;
        followersTableView.separatorStyle = .none;
        followingTableView.backgroundView = messageLabel;
        followingTableView.separatorStyle = .none;

    }
}

extension UIView {
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addRightBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
}
