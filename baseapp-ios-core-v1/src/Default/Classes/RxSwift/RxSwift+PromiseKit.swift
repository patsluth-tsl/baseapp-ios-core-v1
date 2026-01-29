//
//  RxSwift+PromiseKit.swift
//  baseapp-ios-core-v1
//
//  Created by Pat Sluth on 2018-10-25.
//  Copyright © 2018 SilverLogic. All rights reserved.
//

import Foundation
import PromiseKit
import RxCocoa
import RxSwift

extension Promise: ObservableConvertibleType {
	public typealias Element = Swift.Result<T, Error>
	
	public func asObservable() -> Observable<Element> {
		let (promise, resolver) = Promise<T>.pending()
		
		self.done({
			if promise.isPending && !promise.isRejected {
				resolver.fulfill($0)
			} else {
				resolver.reject(PMKError.cancelled)
			}
		}).catch({
			resolver.reject($0)
		})
		
		return Observable.create({ observable in
			promise.done({
				observable.onNext(.success($0))
			}).catch({
				observable.onNext(.failure($0))
			}).finally({
				observable.onCompleted()
			})
			
			return Disposables.create(with: {
				if promise.isPending {
					resolver.reject(PMKError.cancelled)
				}
			})
		})
	}
}

public extension ObservableConvertibleType {
	func asPromise() -> Promise<Element> {
		let (promise, resolver) = Promise<Element>.pending()
		
		_ = self.asObservable()
			.take(1)
			.subscribe(onNext: {
				resolver.fulfill($0)
			}, onError: {
				resolver.reject($0)
			}, onDisposed: {
				if promise.isPending {
					resolver.reject(PMKError.cancelled)
				}
			})
		
		return promise
	}
}
