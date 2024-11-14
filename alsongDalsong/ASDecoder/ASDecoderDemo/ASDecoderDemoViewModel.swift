import ASDecoder
import Foundation

@MainActor
class ASDecoderDemoViewModel: ObservableObject {
    @Published var userInfo: UserInfo?
    @Published var errorMessage: String?
    @Published var scenario: JSONDataScenarios?
    
    var customDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    func loadUserInfo(from scenario: Scenarios) async {
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
    }
}
