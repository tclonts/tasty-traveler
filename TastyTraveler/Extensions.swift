//
//  Extensions.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/8/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit

extension UIButton {
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        let inside = super.point(inside: point, with: event)
        
        if inside != isHighlighted && event?.type == .touches {
            isHighlighted = inside
        }
        
        return inside
        
    }
    
    func applyGradient(colors: [CGColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.cornerRadius = self.frame.height / 2
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
}

extension UIViewController {
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}

extension UIColor {
    /**
     Creates a UIColor from a HEX String.
     - parameter hexString: HEX String in the format of "#FFFFFF"
     - returns: UIColor
     */
    convenience init(hexString: String) {
        
        let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        
        var color: UInt32 = 0
        // color is passed as an address, it's not a copy
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
    
    /**
     Creates a UIColor from the RGB values provided as integers.
     - parameter red: Red value as an integer (0-255)
     - parameter green: Green value as an integer (0-255)
     - parameter blue: Blue value as an integer (0-255)
     - returns: UIColor
     */
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid value for red component.")
        assert(green >= 0 && green <= 255, "Invalid value for green component.")
        assert(blue >= 0 && blue <= 255, "Invalid value for blue component.")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
}

extension UITextField {
    func setLeftPadding(amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPadding(amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
