@testable import ASEncoder
import Foundation
import Testing

struct ASEncoderTests {
    struct TestModel: Encodable, Equatable {
        let name: String
        let age: Int
        let birthDate: Date
    }

    @Test func testmodel_인코딩() async throws {
        let dateFormatter = ISO8601DateFormatter()
        let dateString = "2000-01-01T00:00:00Z"
        let date = dateFormatter.date(from: dateString)!
        let testModel = TestModel(name: "아이유", age: 30, birthDate: date)
        let jsonData = try ASEncoder.encode(testModel)
        #expect(jsonData != nil)

        let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
        #expect(json is [String: Any])

        let dictionary = json as! [String: Any]
        #expect(dictionary["name"] as? String == "아이유")
        #expect(dictionary["age"] as? Int == 30)
        #expect(dictionary["birthDate"] as? String == dateString)
    }
}
