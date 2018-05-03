//
//  TextInputAccessoryView.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/1/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia

protocol TextInputAccessoryViewDelegate {
    func didSend(for message: String)
}

class TextInputAccessoryView: UIView {
    
    var delegate: TextInputAccessoryViewDelegate?
    
    func clearMessageTextField() {
        inputTextView.text = nil
        inputTextView.showPlaceholderLabel()
    }
    
    fileprivate let inputTextView: TextInputTextView = {
        let tv = TextInputTextView()
        tv.isScrollEnabled = false
        let font = ProximaNova.regular.of(size: adaptConstant(16))
        tv.font = font
        tv.placeholderLabel.font = font
        tv.layer.borderColor = Color.lightGray.cgColor
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = 16
        tv.textContainerInset.right = 35
        tv.textContainerInset.left = 4
        return tv
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "sendButton"), for: .normal)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    @objc func handleSend() {
        guard let messageText = inputTextView.text, messageText != "" else { return }
        delegate?.didSend(for: messageText)
        sendButton.isEnabled = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        autoresizingMask = .flexibleHeight
        
        backgroundColor = .white
        
        sv(inputTextView, sendButton)
        
        inputTextView.top(8).left(8).bottom(8).right(8)
        
        sendButton.bottom(12).right(12).width(27).height(27)
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
