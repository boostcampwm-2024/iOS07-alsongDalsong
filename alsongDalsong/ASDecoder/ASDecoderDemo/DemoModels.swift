import Foundation

struct UserInfo: Decodable, Identifiable {
    let id: Int
    let userName: String
    let userAvatarUrl: URL
    let userBirthDate: Date
    let userStatus: UserStatus
}

enum UserStatus: String, Decodable {
    case waiting
    case humming
}

enum Scenarios {
    case correct
    case missing
    case incorrect

    var string: String? {
        switch self {
            case .correct: return String(data: JSONDataScenarios.correctData, encoding: .utf8)
            case .missing: return String(data: JSONDataScenarios.missingFieldData, encoding: .utf8)
            case .incorrect: return String(data: JSONDataScenarios.incorrectFormatData, encoding: .utf8)
        }
    }
    
    var data: Data {
        switch self {
            case .correct: return JSONDataScenarios.correctData
            case .missing: return JSONDataScenarios.missingFieldData
            case .incorrect: return JSONDataScenarios.incorrectFormatData
        }
    }
}
