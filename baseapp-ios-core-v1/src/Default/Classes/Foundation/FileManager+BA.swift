//
//  FileManager+BA.swift
//  baseapp-ios-core-v1
//
//  Created by Pat Sluth on 2017-10-08.
//  Copyright © 2017 SilverLogic. All rights reserved.
//

import Foundation
import PromiseKit

public extension FileManager {
    func documentsDirectory() throws -> URL {
        guard let directoryURL = urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw Errors.Message("Failed to get documents directory")
        }
        return directoryURL
    }
    
    func documentsDirectoryPromise() -> Promise<URL> {
        return Promise<URL>.wrap({
            try self.documentsDirectory()
        })
    }
    
    func documentsChildDirectory(path components: [String]) throws -> URL {
        var directoryURL = try documentsDirectory()
        for component in components {
            directoryURL = directoryURL.appendingPathComponent(component, isDirectory: true)
        }
        if !directoryURL.isReachableDirectory {
            try self.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        return directoryURL
    }
    
    func documentsChildDirectoryPromise(path components: [String]) -> Promise<URL> {
        return Promise<URL>.wrap({
            try self.documentsChildDirectory(path: components)
        })
    }
    
    func documentsChildDirectory(path components: String...) throws -> URL {
        return try documentsChildDirectory(path: components)
    }
    
    func documentsChildDirectoryPromise(path components: String...) -> Promise<URL> {
        return self.documentsChildDirectoryPromise(path: components)
    }
}
