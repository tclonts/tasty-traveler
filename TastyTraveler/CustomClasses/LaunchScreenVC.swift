//
//  LaunchScreenVC.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/21/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia

class LaunchScreenVC: UIViewController {
    
    let splashLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "Group")
        imageView.height(84).width(84)
        return imageView
    }()
    
    let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading..."
        label.textAlignment = .center
        label.font = UIFont(name: "ProximaNova-SemiBold", size: 16)
        label.textColor = Color.primaryOrange
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        self.view.sv(splashLogo, loadingLabel)
        
        splashLogo.centerInContainer()
        
        loadingLabel.centerHorizontally()
        loadingLabel.Bottom == view.safeAreaLayoutGuide.Bottom - 20
    }
}
