import Foundation
import os.log

public enum Logger {
    private static var logger: os.Logger {
        return os.Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.unknown.app", category: "Logger")
    }

    public static func debug(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        log(.debug, items, separator: separator, terminator: terminator)
    }

    public static func info(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        log(.info, items, separator: separator, terminator: terminator)
    }

    public static func warning(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        log(.warning, items, separator: separator, terminator: terminator)
    }

    public static func error(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        log(.error, items, separator: separator, terminator: terminator)
    }

    public static func critical(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        log(.critical, items, separator: separator, terminator: terminator)
    }

    private static func log(_ level: LogLevel, _ items: [Any], separator: String, terminator _: String) {
        #if DEBUG
            let message = items.map { stringify($0) }.joined(separator: separator)
            switch level {
                case .debug:
                logger.debug("[\(level.rawValue)] \(message, privacy: .private)")
                case .info:
                logger.info("[\(level.rawValue)] \(message, privacy: .private)")
                case .warning:
                logger.warning("[\(level.rawValue)] \(message, privacy: .private)")
                case .error:
                logger.error("[\(level.rawValue)] \(message, privacy: .private)")
                case .critical:
                logger.fault("[\(level.rawValue)] \(message, privacy: .private)")
            }
        #endif
    }

    private static func stringify(_ value: Any) -> String {
        if let array = value as? [Any] {
            return "[" + array.map { stringify($0) }.joined(separator: ", ") + "]"
        }
        if let dict = value as? [AnyHashable: Any] {
            return "{" + dict.map { "\($0.key): \(stringify($0.value))" }.joined(separator: ", ") + "}"
        }
        return "\(value)"
    }
}

enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    case critical = "CRITICAL"
}
