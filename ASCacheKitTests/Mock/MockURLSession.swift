import ASCacheKit
import Foundation

public class MockURLSession: URLSessionProtocol {
    public static var testData: Data?
    public static var testResponse: URLResponse?

    public func data(from url: URL) async throws -> (Data, URLResponse) {
        let data = MockURLSession.testData ?? Data()
        let response = MockURLSession.testResponse ?? URLResponse()
        return (data, response)
    }
}
