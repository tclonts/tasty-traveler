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
let screenAspectRatio = screenHeight / iPhone8ScreenHeight

func adaptConstant(_ constant: CGFloat) -> CGFloat {
    return constant * screenAspectRatio
}

struct Color {
    static let blackText = UIColor(hexString: "2A2A2A")
    static let darkText = UIColor(hexString: "4D4D4D")
    static let darkGrayText = UIColor(hexString: "717171")
    static let primaryOrange = UIColor(hexString: "FF8200")
}
