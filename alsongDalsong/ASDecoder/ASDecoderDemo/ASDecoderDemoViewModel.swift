import ASDecoder
import Foundation

@MainActor
class ASDecoderDemoViewModel: ObservableObject {
    @Published var userInfo: UserInfo?
    @Published var errorMessage: String?
    @Published var jsonString: String?

    var customDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    let modelString = """
            struct UserInfo {
                let id: Int
                let userName: String
                let userAvatarUrl: URL
                let userBirthDate: Date
                let userStatus: UserStatus
            }
        """

    func loadUserInfo(from scenario: Scenarios) async {
        jsonString = scenario.string
        let result: Result<Data, Error> = .success(scenario.data)

        do {
            userInfo = try await ASDecoder.handleResponse(result: result)
        } catch {
            userInfo = nil
            errorMessage = "디코딩 실패: \(error.localizedDescription)"
        }
    }

    func reset() {
        userInfo = nil
        errorMessage = nil
        jsonString = nil
    }
}
