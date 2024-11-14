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

    @Test func Endpoint_업데이트() async throws {
        let updatedEndpoint = endpoint.update(\.method, with: .patch)
        #expect(updatedEndpoint == FirebaseEndpoint(path: .auth, method: .patch))

        let twiceUpdatedEndpoint = endpoint
            .update(\.headers, with: ["hello": "world"])
            .update(\.body, with: testData)
        #expect(twiceUpdatedEndpoint.headers == ["hello": "world"])
        #expect(twiceUpdatedEndpoint.body == testData)
    }

    @Test func NetworkManager_올바른_응답() async throws {
        let mockURLSession = MockURLSession()
        let networkManager = ASNetworkManager(urlSession: mockURLSession)
        mockURLSession.testData = testData
        mockURLSession.testResponse = testResponse

        let response = try await networkManager.sendRequest(to: endpoint)
        #expect(response == testData)
    }

    @Test func NetworkManager_잘못된_응답() async throws {
        let networkManager = ASNetworkManager(urlSession: MockURLSession())

        await #expect(throws: ASNetworkErrors.self, performing: {
            _ = try await networkManager.sendRequest(to: endpoint)
        })
    }
}
