import Foundation

struct FirebaseEndpoint: Endpoint, Equatable {
    let scheme: String = "https"
    // TODO: - firebase api에 맞는 host 넣기
    let host: String = "google.com"
    var path: Path
    var method: HTTPMethod
    var headers: [String: String]
    var body: Data?
    var queryItems: [URLQueryItem]?

    init(path: Path, method: HTTPMethod) {
        self.path = path
        self.method = method
        headers = [:]
    }

    // TODO: - firebase api/cloud func에 맞는 path 넣기
    enum Path: CustomStringConvertible {
        case auth
        var description: String {
            switch self {
                case .auth:
                    "/auth"
            }
        }
    }
}
