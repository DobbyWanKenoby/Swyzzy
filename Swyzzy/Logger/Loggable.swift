import Foundation
import Swinject

protocol Loggable {
    var logResolver: Resolver { get }
    var logger: Logger { get }
}

extension Loggable {
    var logger: Logger {
        logResolver.resolve(Logger.self)!
    }
}
