import Foundation

public struct ASEndpoint {
    var scheme: String
    var host: String
    var path: String
    var method: HTTPMethod
    var headers: [String: String]?
    var body: Data?
    var queryItems: [URLQueryItem]?
    var url: URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems
        return components.url
    }
    
    init(
        scheme: String = "https",
        host: String,
        path: String,
        method: HTTPMethod,
        headers: [String: String]? = nil,
        body: Data? = nil,
        queryItems: [URLQueryItem]? = nil
    ) {
        self.scheme = scheme
        self.host = host
        self.path = path
        self.method = method
        self.headers = headers
    }
}
