@testable import ASNetworkKit
import Foundation
import Testing

struct ASNetworkKitTests {
    var networkManager = ASNetworkManager(urlSession: MockURLSession())
    var endpoint = FirebaseEndpoint(path: .auth, method: .get)
    let testData = "hello, world!".data(using: .utf8)!
    let testResponse = HTTPURLResponse(url: URL(string: "https://www.google.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!

    @Test func Endpoint_생성() async throws {
        #expect(endpoint == FirebaseEndpoint(path: .auth, method: .get))
    }
}
