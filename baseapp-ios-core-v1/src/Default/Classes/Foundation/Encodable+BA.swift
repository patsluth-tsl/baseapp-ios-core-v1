//
//  Encodable+BA.swift
//  baseapp-ios-core-v1
//
//  Created by Pat Sluth on 2017-10-08.
//  Copyright © 2017 SilverLogic. All rights reserved.
//

import Foundation

public extension Encodable {
    func encode<T>(_ type: T.Type, encoder: (inout JSONEncoder) -> Void) throws -> T {
        var _encoder = JSONEncoder()
        _encoder.dateEncodingStrategy = .formatted(DateFormatter.properISO8601)
        _encoder.outputFormatting = .prettyPrinted
        
        encoder(&_encoder)
        
        return try self.encode(type, encoder: encoder)
    }
    
    func encode<T>(_ type: T.Type, encoder: JSONEncoder? = nil) throws -> T {
        let encoder = encoder ?? {
            let _encoder = JSONEncoder()
            _encoder.dateEncodingStrategy = .formatted(DateFormatter.properISO8601)
            _encoder.outputFormatting = .prettyPrinted
            return _encoder
            }()
        let data = try encoder.encode(self)
        
        switch type {
        case is Data.Type:
            // swiftlint:disable:next force_cast
            return data as! T
        case is String.Type:
            if let string = String(data: data, encoding: String.Encoding.utf8) {
                // swiftlint:disable:next force_cast
                return string as! T
            }
        default:
            let jsonObject = try JSONSerialization.jsonObject(
                with: data,
                options: [.allowFragments]
            )
            if jsonObject is T {
                // swiftlint:disable:next force_cast
                return jsonObject as! T
            }
        }
        
        throw Errors.Encoding(self, codingPath: [])
    }
}
