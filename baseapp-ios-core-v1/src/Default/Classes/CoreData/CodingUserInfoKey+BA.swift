//
//  CodingUserInfoKey+BA.swift
//  baseapp-ios-core-v1
//
//  Created by Pat Sluth on 2019-10-16.
//  Copyright © 2019 SilverLogic. All rights reserved.
//

import CoreData
import Foundation

public extension CodingUserInfoKey {
    public static let managedObjectContext = CodingUserInfoKey(
        rawValue: "\(NSManagedObjectContext.self)"
    )!
}
