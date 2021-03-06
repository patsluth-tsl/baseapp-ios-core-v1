//
//  Configurable.swift
//  baseapp-ios-core-v1
//
//  Created by Pat Sluth on 2019-02-25.
//  Copyright © 2019 SilverLogic. All rights reserved.
//

import Foundation

@discardableResult
func configure<T>(_ object: T, _ block: (T) -> Void) -> T {
    block(object)
    
    return object
}

@discardableResult
func Configure<T>(_ object: T, _ block: (T) -> Void) -> T {
    block(object)
    
    return object
}

public protocol Configurable {}

extension NSObject: Configurable {}

public extension Configurable {
    @discardableResult
    func configure(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
    
    func map<T>(_ block: (Self) -> T) -> T {
        return block(self)
    }
}
