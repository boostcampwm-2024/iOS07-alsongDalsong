import Foundation

public struct ImageEndpoint: Endpoint {
    public var scheme: String
    public var host: String
    public var path: Path
    public var method: HTTPMethod
    public var headers: [String: String]
    public var body: Data?
    public var queryItems: [URLQueryItem]?
    public var url: URL?

    public init?(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        self.url = url
        self.scheme = components.scheme ?? ""
        self.host = components.host ?? ""
        self.method = .get
        self.path = .image
        self.headers = [:]
    }

    public enum Path: CustomStringConvertible {
        case image
        public var description: String {
            switch self {
            case .image:
                ""
            }
        }
    }
}
