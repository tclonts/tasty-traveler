//
//  PointsVC.swift
//  TastyTraveler
//
//  Created by Tyler Clonts on 8/28/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import FirebaseAuth

class PointsVC: UIViewController {
    
    var updatedNotifications = [UserNotification]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navBarConfiguration()
        
        
    
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @objc func closePoints() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func navBarConfiguration() {
        self.navigationItem.title = "Points"
        self.view.backgroundColor = UIColor(hexString: "F8F8FB")
        let leftBarButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closePoints))
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = Color.blackText
    }
}
