//
//  Range+clamp.swift
//  baseapp-ios-core-v1
//
//  Created by Pat Sluth on 2017-09-30.
//  Copyright © 2017 SilverLogic. All rights reserved.
//

import Foundation


public protocol RangeClamp {
    associatedtype B: Comparable
    
    func clamp(_ value: B) -> B
}

public protocol LowerBoundedRange: RangeClamp {
    var lowerBound: B { get }
}

public protocol UpperBoundedRange: RangeClamp {
    var upperBound: B { get }
}

public protocol BoundedRange: LowerBoundedRange, UpperBoundedRange {
}


extension RangeClamp where Self: LowerBoundedRange {
    public func clamp(_ value: B) -> B {
        return Swift.max(value, lowerBound)
    }
}

extension RangeClamp where Self: UpperBoundedRange {
    public func clamp(_ value: B) -> B {
        return Swift.min(value, upperBound)
    }
}


extension RangeClamp where Self: BoundedRange {
    public func clamp(_ value: B) -> B {
        return Swift.min(Swift.max(value, lowerBound), upperBound)
    }
}

extension ClosedRange: BoundedRange {
    public typealias B = Bound
}

extension Range: BoundedRange {
    public typealias B = Bound
}

extension PartialRangeFrom: LowerBoundedRange {
    public typealias B = Bound
}

extension PartialRangeThrough: UpperBoundedRange {
    public typealias B = Bound
}

extension PartialRangeUpTo: UpperBoundedRange {
    public typealias B = Bound
}
