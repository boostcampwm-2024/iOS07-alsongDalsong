import Foundation

public enum ASNetworkErrors: Error, CustomStringConvertible {
    case serverError(message: String)
    case urlError
    case responseError

    public var description: String {
        switch self {
            case let .serverError(message: message):
                return message
            case .urlError:
                return "URL에러: URL이 제대로 입력되지 않았습니다."
            case .responseError:
                return "응답 에러: 서버에서 응답이 없거나 잘못된 응답이 왔습니다."
        }
    }
}
