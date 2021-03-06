//
//  UIColor+BA.swift
//  baseapp-ios-core-v1
//
//  Created by Pat Sluth on 2017-11-02.
//  Copyright © 2017 SilverLogic. All rights reserved.
//

import CoreGraphics
import Foundation
import UIKit

public extension UIColor {
    func with(alpha: CGFloat) -> UIColor {
		return withAlphaComponent(alpha)
	}
	
	func lighter(by percentage: CGFloat) -> UIColor {
		return adjusting(by: abs(percentage))
	}
	
	func darker(by percentage: CGFloat) -> UIColor {
		return adjusting(by: abs(percentage) * -1.0)
	}
	
	/**
	-ve percentage = darker
	+ve percentage = lighter
	*/
	func adjusting(by percentage: CGFloat) -> UIColor {
		guard var rgba = try? getRGBA() else { return self }
		let percentage = (-1.0...1.0).clamp(percentage)
		
		rgba.r += (rgba.r * percentage)
		rgba.g += (rgba.g * percentage)
		rgba.b += (rgba.b * percentage)
		
		return rgba.uiColor
	}
    
	func brighter(by percentage: CGFloat) -> UIColor {
		return adjustingBrightness(by: abs(percentage))
	}
	
	func dimmmer(by percentage: CGFloat) -> UIColor {
		return adjustingBrightness(by: abs(percentage) * -1.0)
	}
	
	/**
	-ve percentage = brighter
	+ve percentage = dimmmer
	*/
	func adjustingBrightness(by percentage: CGFloat) -> UIColor {
		guard var hsba = try? getHSBA() else { return self }
		let percentage = (-1.0...1.0).clamp(percentage)
		
		switch hsba.b {
		case 0.0:
			hsba.b += (percentage)
		case 1.0:
			hsba.b += (hsba.b * percentage)
		default:
			hsba.s -= (hsba.s * percentage)
		}
		
		return hsba.uiColor
	}
	
	
	/// Calculates a nice constrasting color (good for selecting a text color that looks good over a background color)
	/// Converted from https://stackoverflow.com/questions/28644311/how-to-get-the-rgb-code-int-from-an-uicolor-in-swift
    /// Will return either white or black
	func contrastingColor(fallback: UIColor) -> UIColor {
		guard let rgba = try? getRGBA() else { return fallback }
		
		// Counting the perceptive luminance - human eye favors green color...
		let a = 1.0 - (0.299 * rgba.r + 0.587 * rgba.g + 0.114 * rgba.b)
		if a < 0.5 {    // bright colors - black font
			return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
		} else {        // dark colors - white font
			return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		}
	}
    
    /// Similar to `contrastingColor`, except will return a lighter or darker version of `self`
    func tintedContrastingColor() -> UIColor? {
        guard let rgba = try? getRGBA() else { return nil }
        
        // Counting the perceptive luminance - human eye favors green color...
        let a = 1.0 - (0.299 * rgba.r + 0.587 * rgba.g + 0.114 * rgba.b)
        if a < 0.5 {
            return self.darker(by: a)
        } else {
            return self.lighter(by: a)
        }
    }
}
