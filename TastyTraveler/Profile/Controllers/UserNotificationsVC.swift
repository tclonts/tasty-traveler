//
//  UserNotificationsVC.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/21/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserNotificationsVC: UITableViewController {
    
    var updatedNotifications = [UserNotification]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure navigation bar
        self.navigationItem.title = "Notifications"
        let leftBarButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeNotifications))
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = Color.blackText
        
        // Configure tableView
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        tableView.register(UserNotificationCell.self, forCellReuseIdentifier: "userNotificationCell")
        
        reloadNotifications()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadNotifications), name: Notification.Name("ReloadNotifications"), object: nil)
    }
    
    @objc func reloadNotifications() {
        
        updatedNotifications.removeAll()
        
        FirebaseController.shared.unreadNotificationsCount = 0
        NotificationCenter.default.post(name: Notification.Name("UpdateTabBadge"), object: nil)
        
        guard let userID = Auth.auth().currentUser?.uid else { print("User is not logged in."); return }
        
        
        FirebaseController.shared.userNotifications.forEach { (notification) in
            var newNotification = notification
            newNotification.isUnread = false
            
            self.updatedNotifications.append(newNotification)
            self.updatedNotifications.sort(by: { (n1, n2) -> Bool in
                n1.creationDate > n2.creationDate
            })
            self.tableView.reloadData()
            
            FirebaseController.shared.ref.child("users").child(userID).child("notifications").child(notification.uid).child("isUnread").setValue(false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        view.height(1)
        view.width(tableView.frame.width)
        return view
    }
    
    @objc func closeNotifications() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return updatedNotifications.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = updatedNotifications[indexPath.row].user
        
        let profileVC = ProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        profileVC.isMyProfile = false
        profileVC.userID = user.uid
        self.present(profileVC, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userNotificationCell", for: indexPath) as! UserNotificationCell
        
        let notification = updatedNotifications[indexPath.row]
        cell.notification = notification
        
        return cell
    }
}
