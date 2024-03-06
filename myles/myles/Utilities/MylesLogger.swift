//
//  MylesLogger.swift
//  myles
//
//  Created by Max Rogers on 12/8/23.
//

import Foundation
import OSLog


struct MylesLogger {
    
    static private var loggers: [String : Logger] = [:]
    
    static var logLevel: LogLevel = .verbose
    
    /// Logs an app event
    /// - Parameters:
    ///   - logType: error, fatal (kills app), warning, success, action, cancelled
    ///   - message: Simple message to log
    ///   - sender: String describing callsite
    ///   - verbose: Additional log messaging to provide
    static func log(_ logType: LogType, _ message: String, sender: String) {
        guard logLevel != .none else { return }
        let logger = loggers[sender] ?? Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: sender)
        if loggers[sender] == nil {
            loggers[sender] = logger
        }
        switch logType {
        case .error:
            logger.error("\(message)")
        case .fatal:
            logger.critical("\(message)")
        case .warning:
            logger.warning("\(message)")
        case .success:
            logger.info("\(message)")
        case .action:
            logger.notice("\(message)")
        case .cancelled:
            logger.warning("\(message)")
        }
    }
    
}

enum LogType: String {
    case error
    case fatal
    case warning
    case success
    case action
    case cancelled
}

enum LogLevel {
    case none, standard, verbose
}
