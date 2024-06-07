//
//  RBLog.swift
//
//  Vision OS - From Zero to Hero
//  This code was written as part of a tutorial at https://visionos.substack.com
//
//  Created by Roger Boesch on 01/01/2024.
//
//  DISCLAIMER:
//  The intention of this tutorial is not to always write the best possible code but
//  to show different ways to create a game or app that even can be published.
//  I will also refactor a lot during the tutorial and improve things step by step
//  or even show completely different approaches.
//
//  Feel free to use the code in the way you want :)
//

import Foundation
import UIKit
import SceneKit

public enum RBLogSeverity : Int {
    case trace = 0
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
    case fatal = 5
}

typealias RBLogHandler = (String, RBLogSeverity) -> ()

public class RBLog: NSObject {
    private static var _severity = RBLogSeverity.debug
    private static var _handler: RBLogHandler?              // Only one additionall log handler supported for now
    
    // MARK: - Properties
    
    static var severity: RBLogSeverity {
        get {
            return _severity
        }
        set(value) {
            _severity = value
        }
    }

    static var handler: RBLogHandler? {
        get {
            return _handler
        }
        set(value) {
            _handler = value
        }
    }

    // MARK: - Logging severity
    
    fileprivate static func fatal(message: String) {
        if (RBLogSeverity.fatal.rawValue >= RBLog.severity.rawValue) {
            RBLog.log(message: message, severity: .fatal)
        }
    }
        
    fileprivate static func error(message: String) {
        if (RBLogSeverity.error.rawValue >= RBLog.severity.rawValue) {
            RBLog.log(message: message, severity: .error)
        }
    }

    fileprivate static func warning(message: String) {
        if (RBLogSeverity.warning.rawValue >= RBLog.severity.rawValue) {
            RBLog.log(message: message, severity: .warning)
        }
    }

    fileprivate static func info(message: String) {
        if (RBLogSeverity.info.rawValue >= RBLog.severity.rawValue) {
            RBLog.log(message: message, severity: .info)
        }
    }

    fileprivate static func debug(message: String) {
        if (RBLogSeverity.debug.rawValue >= RBLog.severity.rawValue) {
            RBLog.log(message: message, severity: .debug)
        }
    }

    fileprivate static func trace(message: String) {
        if (RBLogSeverity.trace.rawValue >= RBLog.severity.rawValue) {
            RBLog.log(message: message, severity: .trace)
        }
    }

    // MARK: - Write logs
    
    private static func log(message: String, severity: RBLogSeverity) {
        if RBLog.handler != nil {
            RBLog.handler!(message, severity)
        }

        switch severity {
        case .trace:
            print("[RBLOG] \(message)")
        case .debug:
            print("[RBLOG] > \(message)")
        case .info:
            print("[RBLOG] INF-\(message)")
        case .warning:
            print("[RBLOG] WRN-\(message)")
        case .error:
            print("[RBLOG] ERR-\(message)")
        case .fatal:
            print("[RBLOG] FAT-\(message)")
        }
    }
}


// MARK: - Short functions

func rbFatal(_ message: String,  _ args: CVarArg...) {
    let str = String(format: message, arguments: args)
    RBLog.fatal(message: str)
}

func rbError(_ message: String,  _ args: CVarArg...) {
    let str = String(format: message, arguments: args)
    RBLog.error(message: str)
}

func rbWarning(_ message: String,  _ args: CVarArg...) {
    let str = String(format: message, arguments: args)
    RBLog.warning(message: str)
}

func rbInfo(_ message: String,  _ args: CVarArg...) {
    let str = String(format: message, arguments: args)
    RBLog.info(message: str)
}

func rbDebug(_ message: String,  _ args: CVarArg...) {
    let str = String(format: message, arguments: args)
    RBLog.debug(message: str)
}

func rbTrace(_ message: String,  _ args: CVarArg...) {
    let str = String(format: message, arguments: args)
    RBLog.trace(message: str)
}
