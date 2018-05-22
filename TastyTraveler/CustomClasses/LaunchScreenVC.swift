//
//  LaunchScreenVC.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/21/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit

class LaunchScreenVC: UIViewController {
    
    let background: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "backgroundImage")
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.sv(background)
        
        background.fillContainer()
    }
}
