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
    static let blue          = UIColor(hexString: "5DA5DA")
    static let orange        = UIColor(hexString: "FAA43A")
    static let green         = UIColor(hexString: "60BD68")
    static let pink          = UIColor(hexString: "F17CB0")
    static let purple        = UIColor(hexString: "B276B2")
    static let yellow        = UIColor(hexString: "DECF3F")
    
    //Badge Colors
    static let Gold          = UIColor(hexString: "A87A00")

    static let Silver        = UIColor(hexString: "9B9AA3")

    static let Bronze        = UIColor(hexString: "8D694D")






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
