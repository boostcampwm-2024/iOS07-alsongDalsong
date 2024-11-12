import Foundation

class MockURLSession: URLProtocol {
    static var testData: Data?
    static var testError: Error?

    override class func canInit(with _: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let data = MockURLSession.testData {
            client?.urlProtocol(self, didLoad: data)
        }
        if let error = MockURLSession.testError {
            client?.urlProtocol(self, didFailWithError: error)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
