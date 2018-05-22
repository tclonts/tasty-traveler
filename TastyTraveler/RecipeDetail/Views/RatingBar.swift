//
//  RatingBar.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/7/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia

class RatingBar: UIView {
    
    let emptyBar: UIView = {
        let view = UIView()
        view.backgroundColor = Color.emptyBar
        return view
    }()
    
    let filledBar: UIView = {
        let view = UIView()
        view.backgroundColor = Color.filledBar
        return view
    }()
    
    var fillRatio: CGFloat?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        layer.masksToBounds = true
        clipsToBounds = true
        
        sv(emptyBar.sv(filledBar))
        
        emptyBar.fillContainer()
        filledBar.left(0).top(0).bottom(0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.height / 2
        
        if let ratio = fillRatio {
            self.filledBar.width(emptyBar.frame.width * ratio)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
