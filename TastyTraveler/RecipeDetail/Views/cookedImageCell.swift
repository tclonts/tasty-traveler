//
//  CookedImageCell.swift
//  TastyTraveler
//
//  Created by Tyler Clonts on 8/25/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia

class CookedImageCell: BaseCell {
    
    static let shared = CookedImageCell()

    
    var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.bold.of(size: 14)
        label.textColor = Color.gray
        label.textAlignment = .center
        label.text = "out"
        return label
    }()
    
    let cookedImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.image = #imageLiteral(resourceName: "avatar")
        imageView.contentMode = .scaleAspectFill
        //        imageView.layer.cornerRadius = 85 / 2
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = Color.primaryOrange.cgColor
        return imageView
    }()
    
    lazy var unselectedBackgroundView: UIView = {
        let backgroundView = UIView()
        //backgroundView.backgroundColor = .white
        let view = UIView()
        backgroundView.sv(view)
        
        view.height(adaptConstant(27))
        view.fillHorizontally()
        view.centerVertically()
        view.layer.borderWidth = 1
        view.layer.borderColor = Color.lightGray.cgColor
        view.layer.cornerRadius = adaptConstant(27) / 2
        view.layer.masksToBounds = true
        
        return backgroundView
    }()
    
    lazy var customSelectedBackgroundView: UIView = {
        let backgroundView = UIView()
        let view = UIView()
        backgroundView.sv(view)
        view.height(adaptConstant(27))
        view.fillHorizontally()
        view.centerVertically()
        view.layer.cornerRadius = adaptConstant(27) / 2
        view.backgroundColor = Color.primaryOrange
        view.layer.masksToBounds = true
        backgroundView.alpha = 1
        view.alpha = 1
        return backgroundView
    }()
    
    override func setUpViews() {
        
        sv(userNameLabel, cookedImageView)

        backgroundView = unselectedBackgroundView
        selectedBackgroundView = customSelectedBackgroundView
        
    }

}
