//
//  UserNotificationsVC.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/21/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit

class UserNotificationsVC: UITableViewController {
    
    var userNotifications = [UserNotification]()
    
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
        tableView.register(UserNotificationCell.self, forCellReuseIdentifier: "userNotificationCell")
        
    }
    
    func observeUserNotifications() {
        
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
        return userNotifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userNotificationCell", for: indexPath) as! UserNotificationCell
        
        return cell
    }
}
