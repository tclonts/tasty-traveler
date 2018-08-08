//
//  Constants.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/14/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit

let screenHeight = UIScreen.main.bounds.size.height
let iPhone8ScreenHeight: CGFloat = 667.0
let iPhoneXScreenHeight: CGFloat = 812.0
let screenAspectRatio = screenHeight / iPhone8ScreenHeight

func adaptConstant(_ constant: CGFloat) -> CGFloat {
    if screenHeight == iPhoneXScreenHeight || screenHeight == iPhone8ScreenHeight {
        return constant
    } else {
        return constant * screenAspectRatio
    }
}

struct Color {
    static let offWhite      = UIColor(hexString: "F8F8FB")
    static let blackText     = UIColor(hexString: "2A2A2A")
    static let darkText      = UIColor(hexString: "4D4D4D")
    static let darkGrayText  = UIColor(hexString: "717171")
    static let primaryOrange = UIColor(hexString: "FF8200")
    static let gray          = UIColor(hexString: "999999")
    static let lightGray     = UIColor(hexString: "CECECE")
    
    static let emptyBar      = UIColor(hexString: "E9E9EB")
    static let filledBar     = UIColor(hexString: "86868A")
}

enum ProximaNova: String {
    case light = "ProximaNova-Light"
    case regular = "ProximaNova-Regular"
    case semibold = "ProximaNova-SemiBold"
    case bold = "ProximaNova-Bold"
    
    func of(size: CGFloat) -> UIFont {
        return UIFont(name: self.rawValue, size: adaptConstant(size))!
    }
}
