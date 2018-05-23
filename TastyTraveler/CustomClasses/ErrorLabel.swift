//
//  ErrorLabel.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/23/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit

class ErrorLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.textColor = .red
        self.font = ProximaNova.bold.of(size: 20)
        self.alpha = 0
    }
    
    func show(withText text: String) {
        self.text = "*"
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
