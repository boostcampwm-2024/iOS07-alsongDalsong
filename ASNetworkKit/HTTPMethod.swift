import Foundation

public enum HTTPMethod: String {
    case get
    case post
    case put
    case patch
    case delete

    public var value: String {
        rawValue.uppercased()
    }
}
