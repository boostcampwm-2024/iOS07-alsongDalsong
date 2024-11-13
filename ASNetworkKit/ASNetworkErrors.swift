import Foundation

public enum ASNetworkErrors: Error, CustomStringConvertible {
    case serverError(message: String)
    case urlError

    public var description: String {
        switch self {
            case let .serverError(message: message):
                return message
            case .urlError:
                return "URL에러: URL이 제대로 입력되지 않았습니다."
        }
    }
}
