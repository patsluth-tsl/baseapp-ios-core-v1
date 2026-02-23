//
//  NSDecodableManagedObject.swift
//  baseapp-ios-core-v1
//
//  Created by Pat Sluth on 2019-11-14.
//  Copyright © 2019 SilverLogic. All rights reserved.
//

import CoreData
import CoreStore
import Foundation

// swiftlint:disable:next type_name
public struct NSDecodableManagedObjectIdentityAttribute {
    public let keyPath: String
    public let cVarArg: CVarArg
    
    public init(_ keyPath: String, _ cVarArg: CVarArg) {
        self.keyPath = keyPath
        self.cVarArg = cVarArg
    }
    
    public func identityPredicate() -> NSPredicate {
        return NSPredicate(format: "\(keyPath) == \(cVarArg)")
    }
}

public protocol NSDecodableManagedObject: NSManagedObject {
    typealias IdentityAttribute = NSDecodableManagedObjectIdentityAttribute
    
    static func identityAttribute(from decoder: Decoder) throws -> IdentityAttribute
    func identityAttribute() -> IdentityAttribute
    
    func update(with decoder: Decoder) throws
}

public enum NSDecodableManagedObjectCreate<T>
where T: NSDecodableManagedObject {
    public final class One: Decodable {
        public let object: T
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            guard let dataStack = decoder.userInfo[.dataStack] as? DataStack else {
                fatalError("Decoder userInfo.dataStack is null!")
            }
            let _object = try dataStack.perform(
                synchronous: { (transaction) in
                    let _object = transaction.create(Into<T>())
                    try _object.update(with: decoder)
                    return _object
                },
                waitForAllObservers: false
            )
            object = try dataStack.fetchExisting(_object)!
        }
    }
    
    public final class Many: Decodable {
        public let objects: [T]
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            objects = try container.decode([One].self).map({ $0.object })
        }
    }
}


public enum NSDecodableManagedObjectUpsert<T>
where T: NSDecodableManagedObject {
    public final class One: Decodable {
        public let object: T
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            guard let dataStack = decoder.userInfo[.dataStack] as? DataStack else {
                fatalError("Decoder userInfo.dataStack is null!")
            }
            let identityAttribute = try T.identityAttribute(from: decoder)
            let _object = try dataStack.perform(
                synchronous: { (transaction) in
                    let _object = try transaction.fetchOne(From<T>(), Where<T>(identityAttribute.identityPredicate())) ?? transaction.create(Into<T>())
                    try _object.update(with: decoder)
                    return _object
                },
                waitForAllObservers: false
            )
            object = try dataStack.fetchExisting(_object)!
        }
    }
    
    public final class Many: Decodable {
        public let objects: [T]
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            objects = try container.decode([One].self).map({ $0.object })
        }
    }
}


public extension NSObjectProtocol
where Self: NSManagedObject, Self: NSDecodableManagedObject {
    typealias Create = NSDecodableManagedObjectCreate<Self>
    typealias Upsert = NSDecodableManagedObjectUpsert<Self>
}


public extension Optional
where Wrapped: NSManagedObject, Wrapped: NSDecodableManagedObject {
    typealias Create = NSDecodableManagedObjectCreate<Wrapped>?
    typealias Upsert = NSDecodableManagedObjectUpsert<Wrapped>?
}


public extension NSDecodableManagedObject {
    /// `NSFetchRequest` that will should a single `NSDecodableManagedObject` matching identityAttribute
    static func uniqueFetchRequest(matching identityAttribute: IdentityAttribute) -> NSFetchRequest<Self> {
        let fetchRequest = NSFetchRequest<Self>(entityName: String(describing: self))
        fetchRequest.predicate = NSPredicate(
            format: "\(identityAttribute.keyPath) == \(identityAttribute.cVarArg)"
        )
        fetchRequest.returnsObjectsAsFaults = false
        return fetchRequest
    }
}
