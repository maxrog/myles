//
//  Logger.swift
//  myles
//
//  Created by Max Rogers on 12/8/23.
//

import Foundation

struct Logger {
    
    static var logLevel: LogLevel = .verbose
    
    /// Log an app event
    /// - Parameters:
    ///   - logType: error, fatal, warning, success, action, cancelled
    ///   - message: Simple message to log
    ///   - sender: String describing callsite
    ///   - verbose: Additional log messaging to provide
    static func log(_ logType: LogType, _ message: String, sender: String, verbose: String? = nil) {
        guard logLevel != .none else { return }
        switch logType {
        case .error:
            print("📕 Error:\(sender) \(message)")
        case .fatal:
            print("📕 FATAL:\(sender) - \(message)")
        case .warning:
            print("📙:\(sender) - \(message)")
        case .success:
            print("📗:\(sender) - \(message)")
        case .action:
            print("📓:\(sender) - \(message)")
        case .cancelled:
            print("📘:\(sender) - \(message)")
        }
        if let verbose = verbose, logLevel == .verbose {
            print(
                """
                \(sender)
                \(verbose)
              """
            )
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
