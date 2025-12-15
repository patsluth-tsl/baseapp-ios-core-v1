//
//  AppLogger.swift
//  baseapp-ios-core-v1
//
//  Created by Pat Sluth on 2017-10-08.
//  Copyright © 2017 SilverLogic. All rights reserved.
//

import Foundation
import SwiftyBeaver

// MARK: - Log Level Type

/// An enum that specifies the level type of logging.
public enum LogLevelType: Int {
    case verbose
    case debug
    case info
    case warning
    case error
}


// MARK: - App Logger

/// A singleton responsible for logging operations in the application. Also an abstraction layer for managing
/// all logging communication to SwiftyBeaver.
public final class AppLogger {
    
    // MARK: - Shared Instance
    public static let shared = AppLogger()
    
    
    // MARK: - Private Instance Attributes
    fileprivate let _swiftyLogger: SwiftyBeaver.Type
    
    
    // MARK: - Initializers
    
    /// Initializes a shared instance of `AppLogger`.
    private init() {
        _swiftyLogger = SwiftyBeaver.self
//        configureLogging()
    }
}


// MARK: - Public Instance Methods For Logging
public extension AppLogger {
    /// Takes a message and logs it to SwiftyBeaver.
    ///
    /// - Parameters:
    ///   - message: A `String` representing the message that would be logged in the console and in the log
    ///              file of SwiftyBeaver.
    ///   - logLevelType: A `LogLevelType` representing the log level type to use when logging.
    ///   - debugOnly: A `Bool` indicating if it should log only when the application is running in `DEBUG`
    ///                or not.
    @available(*, deprecated, message: "New example usage logger.log(level: .verbose, when: .debugOnly, message)")
    func logMessage(_ message: String, for logLevelType: LogLevelType, debugOnly: Bool = false) {
        guard let logLevel = SwiftyBeaver.Level(rawValue: logLevelType.rawValue) else { return }
        logger.log(
            level: logLevel,
            when: (debugOnly) ? .debugOnly : .always,
            message
        )
    }
}


// MARK: - Private Instance Methods
private extension AppLogger {

    /// Configures logging for the application at launch.
    private func configureLogging() {
        let loggingFormat = "$DHH:mm:ss$d $C$L$c: $M"
        let consoleDestination = ConsoleDestination()
        consoleDestination.format = loggingFormat
        _swiftyLogger.addDestination(consoleDestination)
        let fileDestinationOne = FileDestination()
        fileDestinationOne.format = loggingFormat
        _swiftyLogger.addDestination(fileDestinationOne)
        // Check if running in unit test target
        if ProcessInfo.isRunningUnitTests {
            // Only need standard cache directory
            // with special formatting
            fileDestinationOne.format = "$M"
            _swiftyLogger.addDestination(fileDestinationOne)
            return
        }
        fileDestinationOne.format = loggingFormat
        _swiftyLogger.addDestination(fileDestinationOne)
        let fileDestinationTwo = FileDestination()
        fileDestinationTwo.format = loggingFormat
        fileDestinationTwo.logFileURL = URL(fileURLWithPath: "/tmp/swiftybeaver.log")
        _swiftyLogger.addDestination(fileDestinationTwo)
    }
}
