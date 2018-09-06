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
    let margin = adaptConstant(16)
    
    var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.bold.of(size: 16)
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
        return imageView
    }()
    
    lazy var unselectedBackgroundView: UIView = {
        let backgroundView = UIView()
        //        backgroundView.backgroundColor = .white
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
        view.backgroundColor = .blue
        view.layer.masksToBounds = true
        backgroundView.alpha = 1
        view.alpha = 1
        return backgroundView
    }()
    
    override func setUpViews() {
        let stackView = UIStackView(arrangedSubviews: [cookedImageView, userNameLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 0
        userNameLabel.width(100)
        userNameLabel.Top == cookedImageView.Bottom

//        stackView.height(self.frame.height)
        cookedImageView.height(self.frame.height - 27)
        cookedImageView.width(self.frame.width)
        
        sv(stackView)
        
        
    }
    
}
