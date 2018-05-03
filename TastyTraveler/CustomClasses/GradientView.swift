//
//  GradientView.swift
//  TastyTraveler
//
//  Created by Michael Bart on 4/27/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit

@IBDesignable class GradientView: UIView {
    
    private var gradientLayer: CAGradientLayer!
    
    var topColor: UIColor = .red {
        didSet {
            setNeedsLayout()
        }
    }
    
    var bottomColor: UIColor = .yellow {
        didSet {
            setNeedsLayout()
        }
    }
    
    var shadowColor: UIColor = .clear {
        didSet {
            setNeedsLayout()
        }
    }
    
    var shadowX: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var shadowY: CGFloat = -3 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var shadowBlur: CGFloat = 3 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var startPointX: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var startPointY: CGFloat = 0.5 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var endPointX: CGFloat = 1 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var endPointY: CGFloat = 0.5 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var cornerRadius: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        self.gradientLayer = self.layer as! CAGradientLayer
        self.gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        self.gradientLayer.startPoint = CGPoint(x: startPointX, y: startPointY)
        self.gradientLayer.endPoint = CGPoint(x: endPointX, y: endPointY)
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = CGSize(width: shadowX, height: shadowY)
        self.layer.shadowRadius = shadowBlur
        self.layer.shadowOpacity = 1
        
    }
    
    func animate(duration: TimeInterval, newTopColor: UIColor, newBottomColor: UIColor) {
        let fromColors = self.gradientLayer?.colors
        let toColors: [AnyObject] = [ newTopColor.cgColor, newBottomColor.cgColor]
        self.gradientLayer?.colors = toColors
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = fromColors
        animation.toValue = toColors
        animation.duration = duration
        animation.isRemovedOnCompletion = true
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.gradientLayer?.add(animation, forKey:"animateGradient")
    }
}
