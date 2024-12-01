import Foundation

public enum Status: String, Codable {
    case humming
    case rehumming
    case waiting
    case hint
    case result
}

extension Status: CustomStringConvertible {
    public var description: String {
        switch self {
        case .humming:
            return "humming"
        case .rehumming:
            return "rehumming"
        case .waiting:
            return "waiting"
        case .hint:
            return "hint"
        case .result:
            return "result"
        }
    }
}
