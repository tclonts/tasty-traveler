//
//  InfoBox.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/7/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit

class InfoBox: UIView {
    
    let infoImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(14))
        label.textColor = Color.darkGrayText
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        
        sv(infoImageView, infoLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
