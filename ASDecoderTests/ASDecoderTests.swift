@testable import ASDecoder
import Foundation
import Testing

struct ASDecoderTests {
    struct SampleData: Decodable, Equatable {
        let id: Int
        let name: String
    }

    @Test func 디코딩_성공() async throws {
        let jsonString = """
                {
                    "id": 1,
                    "name": "아이유"
                }
            """
        let jsonData = jsonString.data(using: .utf8)!
        let result: Result<Data, Error> = .success(jsonData)

        let decodedData: SampleData = try await ASDecoder.handleResponse(result: result)
        #expect(decodedData == SampleData(id: 1, name: "아이유"))
    }
}
