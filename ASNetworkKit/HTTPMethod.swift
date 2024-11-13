import Foundation

internal enum HTTPMethod: String {
    case get
    case post
    case put
    case patch
    case delete

    var value: String {
        rawValue.uppercased()
    }
}
