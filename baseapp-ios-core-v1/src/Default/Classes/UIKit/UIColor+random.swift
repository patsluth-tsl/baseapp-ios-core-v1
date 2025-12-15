//
//  UIColor+random.swift
//  baseapp-ios-core-v1
//
//  Created by Pat Sluth on 2017-07-25.
//  Copyright © 2017 SilverLogic. All rights reserved.
//

import Foundation
import UIKit

public extension UIColor {
    static var random: UIColor {
        // swiftlint:disable:next legacy_random
        let hue = CGFloat(Double(arc4random() % 256) / 256.0)
        // swiftlint:disable:next legacy_random
        let saturation = CGFloat(Double(arc4random() % 128) / 256.0) + 0.5
        // swiftlint:disable:next legacy_random
        let brightness = CGFloat(Double(arc4random() % 128) / 256.0) + 0.5
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
}
