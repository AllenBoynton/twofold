//
//  Theme.swift
//  twofold
//
//  Created by Allen Boynton on 4/13/19.
//  Copyright © 2019 Allen Boynton. All rights reserved.
//

import UIKit

class Theme {
    static let mainFontTheme = "FugazOne-Regular"
    static let secondFontTheme = "HelveticaNeue"
    static let segmentedFont = "HelveticaNeue-Thin"
}

class StickmanTheme: Theme {
    static let stickmanBGColor = UIColor.white
    static let stickmanBorderColor = UIColor.darkGray.cgColor
    static let stickmanTintColor = UIColor.lightGray
    static let stickmanSegForegroundColorNormal = UIColor.black
    static let stickmanSegForegroundColorSelected = UIColor.white
}

class ButterflyTheme: Theme {
    static let butterflyBGColor = UIColor.rgb(red: 247, green: 207, blue: 104)
    static let butterflyBorderColor = UIColor.purple.cgColor
    static let butterflyTintColor = UIColor.rgb(red: 231, green: 80, blue: 69)
    static let butterflySegForegroundColorNormal = UIColor.purple
    static let butterflySegForegroundColorSelected = UIColor.white
}

class BeachTheme: Theme {
    static let beachBGColor = UIColor.rgb(red: 70, green: 215, blue: 215)
    static let beachBorderColor = UIColor.blue.cgColor
    static let beachTintColor = UIColor.rgb(red: 194, green: 178, blue: 128) // beach sand color
    static let beachSegForegroundColorNormal = UIColor.white
    static let beachSegForegroundColorSelected = UIColor.blue
}
