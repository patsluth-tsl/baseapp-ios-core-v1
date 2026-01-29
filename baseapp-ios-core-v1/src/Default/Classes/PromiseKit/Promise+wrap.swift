//
//  Promise+attempt.swift
//  baseapp-ios-core-v1
//
//  Created by Pat Sluth on 2017-09-30.
//  Copyright © 2017 SilverLogic. All rights reserved.
//

import Foundation
import PromiseKit

public extension Promise {
    static func wrap<T>(on dispatchQueue: DispatchQueue = .main,
                        _ block: @escaping () throws -> T) -> Promise<T> {
        return promise_wrap(on: dispatchQueue, block)
    }
    
    static func wrap<T>(on dispatchQueue: DispatchQueue = .main,
                        _ block: @escaping (Resolver<T>) -> Void) -> Promise<T> {
        let (promise, resolver) = Promise<T>.pending()
        dispatchQueue.async(execute: {
            block(resolver)
        })
        return promise
    }
}

public extension Guarantee {
    static func wrap<T>(on dispatchQueue: DispatchQueue = .main,
                        _ block: @escaping () -> T) -> Guarantee<T> {
        return promise_wrap(block)
    }
    
    static func wrap<T>(on dispatchQueue: DispatchQueue = .main,
                        _ block: @escaping ((T) -> Void) -> Void) -> Guarantee<T> {
        let (guarantee, resolver) = Guarantee<T>.pending()
        dispatchQueue.async(execute: {
            block(resolver)
        })
        return guarantee
    }
}

public func promise_wrap<T>(on dispatchQueue: DispatchQueue = .main,
                            _ block: @escaping () throws -> T) -> Promise<T> {
    let (promise, resolver) = Promise<T>.pending()
    dispatchQueue.async(execute: {
        do {
            resolver.fulfill(try block())
        } catch {
            resolver.reject(error)
        }
    })
    return promise
}

public func promise_wrap<T>(on dispatchQueue: DispatchQueue = .main,
                            _ block: @escaping () -> T) -> Guarantee<T> {
    let (guarantee, resolver) = Guarantee<T>.pending()
    dispatchQueue.async(execute: {
        resolver(block())
    })
    return guarantee
}
