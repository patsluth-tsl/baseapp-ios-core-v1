//
//  UIViewController+BA.swift
//  baseapp-ios-core-v1
//
//  Created by Pat Sluth on 2017-12-03.
//  Copyright © 2017 SilverLogic. All rights reserved.
//

import Foundation

#if os(iOS)

public extension NSObjectProtocol
where Self: UIViewController {
    @discardableResult
    func embedIn(parent vc: UIViewController, superview: UIView) -> Self {
        willMove(toParent: vc)
        vc.addChild(self)
        if let stackView = superview as? UIStackView {
            stackView.add(view)
        } else {
            superview.addSubview(view)
        }
        didMove(toParent: vc)
        return self
    }
    
    @discardableResult
    func unEmbed() -> Self {
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
        didMove(toParent: nil)
        return self
    }
}

#endif
