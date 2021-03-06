//
//  UIGestureRecognizer.swift
//  baseapp-ios-core-v1
//
//  Created by Pat Sluth on 2017-12-08.
//  Copyright © 2017 SilverLogic. All rights reserved.
//

import UIKit

#if os(iOS)

public extension UIGestureRecognizer {
    @discardableResult
    func add(to view: UIView) -> Self {
        view.addGestureRecognizer(self)
        return self
    }
}

#endif
