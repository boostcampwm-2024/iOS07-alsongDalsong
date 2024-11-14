import ASNetworkKit
import Foundation

public class MockURLSession: URLSessionProtocol {
    public var testData: Data?
    public var testResponse: HTTPURLResponse?

    public func data(from _: URL) async throws -> (Data, URLResponse) {
        let data = testData ?? Data()
        let response = testResponse ?? URLResponse()
        return (data, response)
    }

    public func data(for _: URLRequest) async throws -> (Data, URLResponse) {
        let data = testData ?? Data()
        let response = testResponse ?? URLResponse()
        return (data, response)
    }
}
