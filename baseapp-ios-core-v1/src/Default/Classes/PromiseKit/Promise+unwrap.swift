//
//  Promise+unwrap.swift
//  baseapp-ios-core-v1
//
//  Created by Pat Sluth on 2019-10-16.
//  Copyright © 2019 SilverLogic. All rights reserved.
//

import Foundation
import PromiseKit


public extension Promise {
    func unwrap(success: @escaping (T) -> Void,
                failure: @escaping (Error) -> Void) {
        done({
            success($0)
        }).catch({
            failure($0)
        })
    }
    
    func unwrap(result: @escaping (Swift.Result<T, Error>) -> Void) {
        done({
            result(.success($0))
        }).catch({
            result(.failure($0))
        })
    }
}

public extension Guarantee {
    func unwrap(success: @escaping (T) -> Void) {
        done({
            success($0)
        })
    }
}
