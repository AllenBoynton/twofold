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
    static let butterflySegForegroundColorSelected = UIColor.black
}

class BeachTheme: Theme {
    static let beachBGColor = UIColor.rgb(red: 70, green: 215, blue: 215)
    static let beachBorderColor = UIColor.blue.cgColor
    static let beachTintColor = UIColor.white
    static let beachSegForegroundColorNormal = UIColor.white
    static let beachSegForegroundColorSelected = UIColor.blue
}

class JungleTheme: Theme {
    static let jungleBGColor = UIColor.rgb(red: 11, green: 102, blue: 35)
    static let jungleBorderColor = UIColor.rgb(red: 186, green: 118, blue: 40)
    static let jungleTintColor = UIColor.rgb(red: 205, green: 175, blue: 138)
    static let jungleSegForegroundColorNormal = UIColor.rgb(red: 111, green: 68, blue: 63)
    static let jungleSegForegroundColorSelected = UIColor.rgb(red: 79, green: 34, blue: 26)
    static let jungleTextColor = UIColor.rgb(red: 163, green: 197, blue: 83)
}
