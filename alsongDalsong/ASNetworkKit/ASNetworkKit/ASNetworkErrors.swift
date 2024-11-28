import Foundation

public enum ASNetworkErrors: Error, LocalizedError {
    case serverError(message: String)
    case urlError
    case responseError
    case FirebaseSignInError
    case FirebaseSignOutError
    case FirebaseListenerError
    
    public var errorDescription: String? {
        switch self {
            case let .serverError(message: message):
                return message
            case .urlError:
                return "URL에러: URL이 제대로 입력되지 않았습니다."
            case .responseError:
                return "응답 에러: 서버에서 응답이 없거나 잘못된 응답이 왔습니다."
            case .FirebaseSignInError:
                return "파이어베이스 에러: 익명 로그인에 실패했습니다."
            case .FirebaseSignOutError:
                return "파이어베이스 에러: 로그아웃에 실패했습니다."
            case .FirebaseListenerError:
                return "파이어베이스 에러: 해당 데이터베이스를 가져오는데 실패했습니다."
        }
    }
}
