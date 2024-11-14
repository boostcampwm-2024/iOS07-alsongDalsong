import Foundation

public struct FirebaseEndpoint: Endpoint, Equatable {
    public let scheme: String = "https"
    // TODO: - firebase api에 맞는 host 넣기
    public let host: String = "google.com"
    public var path: Path
    public var method: HTTPMethod
    // 헤더는 기본적인 것을 넣어두고 필요할 때만 추가하는 게 좋을듯
    public var headers: [String: String]
    public var body: Data?
    public var queryItems: [URLQueryItem]?

    public init(path: Path, method: HTTPMethod) {
        self.path = path
        self.method = method
        headers = [:]
    }

    // TODO: - firebase api/cloud func에 맞는 path 넣기
    public enum Path: CustomStringConvertible {
        case auth
        public var description: String {
            switch self {
                case .auth:
                    "/auth"
            }
        }
    }
}

// MARK: - example functions

public extension FirebaseEndpoint {
    func test(body: Data) -> any Endpoint {
        Self(path: .auth, method: .get)
            .update(\.body, with: body)
    }

    func fetchAllAvatarURLs() -> any Endpoint {
        Self(path: .auth, method: .get)
            .update(\.queryItems, with: [.init(name: "listAvatarUrls", value: "true")])
    }
}