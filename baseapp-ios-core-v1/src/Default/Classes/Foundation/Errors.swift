//
//  Errors.swift
//  baseapp-ios-core-v1
//
//  Created by Pat Sluth on 2017-09-30.
//  Copyright © 2017 SilverLogic. All rights reserved.
//

import Foundation

public enum Errors: LocalizedError {
    case Init(Any.Type)
    case Message(String)
    
    static func Decoding<T>(_ type: T.Type, codingPath: [CodingKey]) -> DecodingError {
        let context = DecodingError.Context(codingPath: [], debugDescription: "Failed to decode \(T.self)")
        return DecodingError.dataCorrupted(context)
    }
    
    static func Encoding<T>(_ value: T, codingPath: [CodingKey]) -> EncodingError {
        let context = EncodingError.Context(codingPath: [], debugDescription: "Failed to encode \(T.self)")
        return EncodingError.invalidValue(value, context)
    }
    
    static func Log(file: String = #file,
                    function: String = #function,
                    line: Int = #line,
                    _ message: String) -> Errors {
        return Errors.Message("\(file.fileNameFull) \(function) \(line) \(message)")
    }
}

extension Errors: CustomStringConvertible {
    public var description: String {
        switch self {
        case Errors.Message(let message):
            return message
        default:
            return debugDescription
        }
    }
}

extension Errors: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case Errors.Init(let type):
            return "Error.Init(\(type))"
        case Errors.Message(let message):
            return "Error.Message(\(message))"
        }
    }
}

extension LocalizedError where Self: CustomStringConvertible {
    public var errorDescription: String? {
        return description
    }
}
