import ASEncoder
import Foundation

public class EncodingDemoViewModel: ObservableObject {
    @Published var userInfo: UserInfo = .init(
        userName: "Rosè",
        userAvaterUrl: URL(string: "www.apple.com")!,
        userBirthDate: .now,
        userStatus: .humming
    )

    @Published var encodedData: Data?
    @Published var jsonDisplayText: String?

    var userAvatarUrl: String {
        get { userInfo.userAvaterUrl.absoluteString }
        set { userInfo.userAvaterUrl = URL(string: newValue) ?? userInfo.userAvaterUrl
            updateJSON()
        }
    }

    func updateJSON() {
        encodedData = try? ASEncoder.encode(userInfo)
        jsonDisplayText = convertToPrettyJSON(from: encodedData)
    }

    private func convertToPrettyJSON(from data: Data?) -> String? {
        guard let data = data else { return nil }
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
            return String(data: prettyData, encoding: .utf8)
        } catch {
            print("JSON formatting failed:", error)
            return nil
        }
    }
}
