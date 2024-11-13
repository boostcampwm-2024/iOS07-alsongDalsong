import Foundation

class RequestBuilder {
    var url: URL
    private var header: [String: String] = [:]
    private var httpMethod: String = ""
    private var body: Data?

    init(using url: URL) {
        self.url = url
    }

    func setHeader(_ header: [String: String]) -> Self {
        self.header = header
        return self
    }

    func setHttpMethod(_ httpMethod: HTTPMethod) -> Self {
        self.httpMethod = httpMethod.value
        return self
    }

    func setBody(_ body: Data?) -> Self {
        self.body = body
        return self
    }

    func build() -> URLRequest {
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = header
        request.httpMethod = httpMethod
        request.httpBody = body
        return request
    }
}
