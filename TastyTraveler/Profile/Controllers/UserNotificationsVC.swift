//
//  UserNotificationsVC.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/21/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit

class UserNotificationsVC: UITableViewController {
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadNotifications), name: Notification.Name("ReloadNotifications"), object: nil)
    }
    
    @objc func reloadNotifications() {
        self.tableView.reloadData()
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
        return FirebaseController.shared.userNotifications.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = FirebaseController.shared.userNotifications[indexPath.row].user
        
        let profileVC = ProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        profileVC.isMyProfile = false
        profileVC.userID = user.uid
        self.present(profileVC, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userNotificationCell", for: indexPath) as! UserNotificationCell
        
        let notification = FirebaseController.shared.userNotifications[indexPath.row]
        cell.notification = notification
        
        return cell
    }
}
