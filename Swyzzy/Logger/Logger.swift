//
//  Logger.swift
//  Swyzzy
//
//  Created by Vasily Usov on 09.11.2021.
//

import Foundation
import Swinject

class Logger {

    private var type: LoggerType
    private var resolver: Resolver
    var prefix: String?

    init(type: LoggerType, resolver: Resolver) {
        self.type = type
        self.resolver = resolver
    }

    func log(_ message: String) {
        logMessage(message)
    }

    func log(_ message: LoggerMessage) {
        logMessage(message.rawValue)
    }

    func log(_ message: LoggerMessage, description: String) {
        logMessage("\(message.rawValue). Description - \(description)")
    }

    private func logMessage(_ message: String) {
        if let prefix = prefix {
            self.type.log("\(prefix) \(message)")
        } else {
            self.type.log(message)
        }
    }

    enum LoggerType {
        case console

        func log(_ message: String) {
            switch self {
            case .console:
                print(message)
            }
        }
    }
}
