//
//  TextInputView.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/22/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia

class TextInputView: UIView {
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        return textView
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.height(1)
        view.backgroundColor = Color.lightGray
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        sv(textView)
        
        
        textView.top(0).left(0).right(0).bottom(0)
        //separatorView.left(0).right(0).bottom(0)
        
        //textView.Bottom == separatorView.Top
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
