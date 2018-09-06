//
//  TagCell.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/26/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia

class TagCell: BaseCell {
    
    //    var tagString: String? {
    //        didSet {
    //            tagLabel.text = tagString!
    //        }
    //    }
    
    let tagLabel: UILabel = {
        let label = UILabel()
        //        label.font = UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(16))
        //        label.textColor = Color.lightGray
        //
        return label
    }()
    
    lazy var unselectedBackgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .white
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
        
        sv(tagLabel)
        tagLabel.centerInContainer()
    
        backgroundView = unselectedBackgroundView
        selectedBackgroundView = customSelectedBackgroundView
        
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.tagLabel.textColor = .white
            } else {
                self.tagLabel.textColor = Color.lightGray
            }
        }
    }
    
}
